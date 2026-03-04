import fs from "fs";
import path from "path";
import { execSync } from "child_process";

// Requires Node >18 for native fetch
const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY;

if (!ANTHROPIC_API_KEY) {
  console.error("Missing ANTHROPIC_API_KEY environment variable");
  process.exit(1);
}

const UPSTREAM_REPO = "https://github.com/mizvekov/get-shit-done.git";
const WORK_DIR = path.join(process.cwd(), ".gsd-sync-tmp");
const ADAPTATION_DOC = path.resolve("docs/adaptation.md");
const WORKFLOWS_DIR = path.resolve("workflows");

// 1. Setup workspace
console.log("Setting up sync workspace...");
if (fs.existsSync(WORK_DIR)) {
  fs.rmSync(WORK_DIR, { recursive: true, force: true });
}
execSync(`git clone ${UPSTREAM_REPO} ${WORK_DIR} --depth 1`, { stdio: "inherit" });

const upstreamVersionObj = JSON.parse(fs.readFileSync(path.join(WORK_DIR, "package.json"), "utf8"));
const upstreamVersion = upstreamVersionObj.version;

const localVersionFile = path.resolve(".gsd-synced-version");
let localVersion = "0.0.0";
if (fs.existsSync(localVersionFile)) {
  localVersion = fs.readFileSync(localVersionFile, "utf8").trim();
}

console.log(`Local version: ${localVersion} | Upstream version: ${upstreamVersion}`);

if (localVersion === upstreamVersion) {
  console.log("Already up to date. Exiting.");
  process.exit(0);
}

// 2. Load context
const adaptationGuide = fs.readFileSync(ADAPTATION_DOC, "utf8");

// Map GSD files to Antigravity files
const fileMap = {
  "commands/gsd/new-project.toml": "gsd-new-project.md",
  "workflows/new-project.md": "gsd-new-project.md",
  "commands/gsd/discuss-phase.toml": "gsd-discuss-phase.md",
  "workflows/discuss-phase.md": "gsd-discuss-phase.md",
  "commands/gsd/plan-phase.toml": "gsd-plan-phase.md",
  "workflows/plan-phase.md": "gsd-plan-phase.md",
  "commands/gsd/execute-phase.toml": "gsd-execute-phase.md",
  "workflows/execute-phase.md": "gsd-execute-phase.md",
  "commands/gsd/verify-work.toml": "gsd-verify-work.md",
  "workflows/verify-work.md": "gsd-verify-work.md",
  "commands/gsd/quick.toml": "gsd-quick.md",
  "workflows/quick.md": "gsd-quick.md",
  "commands/gsd/progress.toml": "gsd-progress.md",
  "commands/gsd/map-codebase.toml": "gsd-map-codebase.md",
  "workflows/map-codebase.md": "gsd-map-codebase.md"
};

// 3. Process each relevant upstream file
const filesToProcess = new Set(Object.values(fileMap));

async function callClaude(systemPrompt, userPrompt) {
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
      "content-type": "application/json"
    },
    body: JSON.stringify({
      model: "claude-3-7-sonnet-20250219",
      max_tokens: 8192,
      system: systemPrompt,
      messages: [{ role: "user", content: userPrompt }]
    })
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Anthropic API error: ${response.status} ${error}`);
  }

  const json = await response.json();
  return json.content[0].text;
}

const systemPrompt = `You are an expert engineer maintaining the Antigravity port of the GSD (Get Shit Done) framework.
Your task is to sync upstream updates from the native Claude Code GSD repo into the Antigravity workflow markdown files.

CRITICAL ARCHITECTURE RULES from adaptation.md:
${adaptationGuide}

INSTRUCTIONS:
1. I will provide you with the latest upstream GSD source code for a specific workflow (the .toml command file and/or the .md workflow instructions).
2. I will provide you with the CURRENT Antigravity workflow file.
3. You must read the upstream source, identify what concepts, XML structures, or workflow logic have changed or improved.
4. You must translate those improvements into the Antigravity paradigm (no gsd-tools, no subagent Task() calls, use notify_user for checkpoints, read files directly).
5. Output the ENTIRE updated Antigravity workflow file inside a \`\`\`markdown block. DO NOT use diffs, output the entire file contents ready to be written to disk.`;

console.log("\nStarting LLM translation sync...");

for (const targetFile of filesToProcess) {
  console.log(`\nReviewing upstream changes for ${targetFile}...`);
  
  // Gather upstream sources that map to this Antigravity file
  let upstreamContent = "";
  for (const [upstreamPath, mappedTarget] of Object.entries(fileMap)) {
    if (mappedTarget === targetFile) {
      const fullPath = path.join(WORK_DIR, upstreamPath);
      if (fs.existsSync(fullPath)) {
        upstreamContent += `\n\n--- UPSTREAM ${upstreamPath} ---\n`;
        upstreamContent += fs.readFileSync(fullPath, "utf8");
      }
    }
  }

  if (!upstreamContent) continue;

  const currentLocalPath = path.join(WORKFLOWS_DIR, targetFile);
  if (!fs.existsSync(currentLocalPath)) {
    console.warn(`Local file ${currentLocalPath} not found. Skipping.`);
    continue;
  }
  const currentLocalContent = fs.readFileSync(currentLocalPath, "utf8");

  const userPrompt = `Here are the LATEST UPSTREAM GSD files that map to this workflow:\n${upstreamContent}\n\nHere is the CURRENT ANTIGRAVITY workflow file:\n\n--- CURRENT ${targetFile} ---\n${currentLocalContent}\n\nAnalyze the upstream changes. If the upstream concepts are already fully represented in the current Antigravity file, output "NO_CHANGES_NEEDED".\n\nOtherwise, translate the upstream improvements into the Antigravity paradigm and output the FULL UPDATED Antigravity markdown file in a \`\`\`markdown block. Include the YAML frontmatter. Keep it under 1000 lines.`;

  try {
    const responseText = await callClaude(systemPrompt, userPrompt);
    
    if (responseText.includes("NO_CHANGES_NEEDED")) {
      console.log(`  No logical updates needed for ${targetFile}.`);
    } else {
      const mdMatch = responseText.match(/```markdown\n([\s\S]*?)```/);
      if (mdMatch && mdMatch[1]) {
        fs.writeFileSync(currentLocalPath, mdMatch[1].trim() + "\n");
        console.log(`  ✓ Updated ${targetFile}`);
      } else {
        console.error(`  Error parsing LLM output for ${targetFile}. Skipping.`);
      }
    }
  } catch (error) {
    console.error(`  API Error on ${targetFile}:`, error.message);
  }
}

// 4. Update the sync version
fs.writeFileSync(localVersionFile, upstreamVersion + "\n");
console.log(`\n✓ Sync complete. Version updated to ${upstreamVersion}`);
