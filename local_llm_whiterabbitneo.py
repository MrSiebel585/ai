
#!/usr/bin/env python3

import os
from llama_cpp import Llama

MODEL_PATH = "/opt/omniscient/ai/models/WhiteRabbitNeo-13B-v1.Q4_K_M.gguf"

def load_model():
    print(f"[*] Loading GGUF model from {MODEL_PATH}")
    return Llama(model_path=MODEL_PATH, n_ctx=4096, n_threads=8)

def run_prompt(llm, prompt):
    print("\n[>] Processing prompt locally with WhiteRabbitNeo...")
    output = llm(prompt, max_tokens=1024, temperature=0.7, top_p=0.95, stop=["\n\n", "User:", "Assistant:"])
    return output['choices'][0]['text'].strip()

def main():
    if not os.path.isfile(MODEL_PATH):
        print(f"[!] Model file not found at {MODEL_PATH}")
        return

    llm = load_model()

    print("\n[+] WhiteRabbitNeo Local LLM (GGUF) is Ready.")
    print("[?] Type your task and goal below. Type 'quit' to exit.\n")

    while True:
        topic = input("Topic or Task (e.g., payload, scan, phishing): ")
        if topic.lower() == 'quit':
            break
        detail = input("Describe target or task details: ")
        if detail.lower() == 'quit':
            break

        prompt = f"{topic.strip().capitalize()}:

{detail.strip()}"
        response = run_prompt(llm, prompt)
        print(f"\n[Response]:\n{response}\n")

if __name__ == "__main__":
    main()
