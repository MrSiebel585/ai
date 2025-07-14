import gpt4all
import os
import sys

model_path = os.path.join(os.path.dirname(__file__), "models", "orca-mini-3b-gguf2-q4_0.gguf")
model = gpt4all.GPT4All(model_path)

def summarize_syslog_entry(entry):
    prompt = f"Summarize the following syslog entry:\n{entry.strip()}"
    summary = model.generate(prompt, max_tokens=100, temp=0.5)
    return summary.strip()

# Support custom file input
syslog_file = sys.argv[1] if len(sys.argv) > 1 else "syslog.txt"
if not os.path.exists(syslog_file):
    print(f"[✘] File not found: {syslog_file}")
    exit(1)

summaries = []
with open(syslog_file, "r") as f:
    for entry in f:
        if entry.strip():
            summaries.append(summarize_syslog_entry(entry))

log_path = "/opt/omniscient/logs/ai_summary.log"
with open(log_path, "a") as log:
    for i, summary in enumerate(summaries, 1):
        output = f"{i:02d}) {summary}"
        print(output)
        log.write(output + "\n")
\
