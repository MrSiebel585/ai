import os
import requests

DEFAULT_MODEL = os.getenv("LLM_MODEL", "mistral-7b-instruct-v0.2.Q4_K_M.gguf")
LLM_ENGINE = os.getenv("LLM_ENGINE", "lmstudio").lower()

def query_openai_compatible(prompt, base_url, model=DEFAULT_MODEL, temperature=0.7):
    try:
        response = requests.post(
            f"{base_url}/chat/completions",
            headers={"Content-Type": "application/json"},
            json={
                "model": model,
                "messages": [{"role": "user", "content": prompt}],
                "temperature": temperature
            },
            timeout=10
        )
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]
    except Exception as e:
        return f"❌ API error: {e}"

def query_ollama(prompt, model=DEFAULT_MODEL):
    try:
        response = requests.post(
            "http://localhost:11434/api/chat",
            headers={"Content-Type": "application/json"},
            json={
                "model": model,
                "messages": [{"role": "user", "content": prompt}],
                "stream": False
            },
            timeout=10
        )
        response.raise_for_status()
        return response.json()["message"]["content"]
    except Exception as e:
        return f"❌ Ollama error: {e}"

def query_gpt4free(prompt):
    try:
        from gpt4free import quora
        return quora.Completion.create(prompt=prompt)
    except Exception as e:
        return f"❌ GPT4Free error: {e}"

def query_llm(prompt, model=DEFAULT_MODEL, temperature=0.7):
    engine = LLM_ENGINE
    if engine == "lmstudio":
        return query_openai_compatible(prompt, "http://localhost:1234/v1", model, temperature)
    elif engine == "ollama":
        return query_ollama(prompt, model)
    elif engine == "huggingface":
        return f"🧠 HuggingFace transformers integration not implemented in router. Use separate pipeline."
    elif engine == "gpt4free":
        return query_gpt4free(prompt)
    else:
        return "❓ Unknown LLM engine. Set LLM_ENGINE to lmstudio, ollama, huggingface, or gpt4free."

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Omniscient LLM Router")
    parser.add_argument("--prompt", "-p", type=str, required=True, help="Prompt to send to LLM")
    parser.add_argument("--model", "-m", type=str, default=DEFAULT_MODEL, help="Model name")
    parser.add_argument("--temperature", "-t", type=float, default=0.7, help="Sampling temperature")
    args = parser.parse_args()

    print(query_llm(args.prompt, model=args.model, temperature=args.temperature))
