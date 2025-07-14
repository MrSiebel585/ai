
import requests

# Hugging Face Inference API configuration (replace with your actual token if applicable)
HF_API_TOKEN = ""
HEADERS = {"Authorization": f"Bearer {HF_API_TOKEN}"}

def query(payload):
    """Sends a request to the Hugging Face Inference API."""
    response = requests.post("https://api-inference.huggingface.co/models/WhiteRabbitNeo/WhiteRabbitNeo-13B-v1", headers=HEADERS, json=payload)
    return response.json()

def main():
    """Main Streamlit app logic."""
    import streamlit as st

    st.title("WhiteRabbitNeo - Cybersecurity Assistant")
    st.write("""
    Welcome to WhiteRabbitNeo! This app helps you with cybersecurity-related questions, tasks,
    and insights. It's designed to assist in analyzing vulnerabilities, suggesting strategies, 
    and providing information on various threats.
    """)

    user_prompt = st.text_area("Enter your cybersecurity-related prompt (or 'quit' to exit):")

    if user_prompt:
        payload = {"inputs": user_prompt}
        output = query(payload)

        if isinstance(output, list) and len(output) > 0 and "generated_text" in output[0]:
            generated_text = output[0]["generated_text"]
            st.write(f"\nWhiteRabbitNeo's Response:\n{generated_text}\n")
        else:
            st.write("\nUnexpected response format.\n")
    elif user_prompt.lower() == 'quit':
        st.stop()
    else:
        st.write("Please enter a cybersecurity-related prompt.")

if __name__ == "__main__":
    main()
