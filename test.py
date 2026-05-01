from google import genai
import os, time, random

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
MODEL = "models/gemini-2-"  # model bạn đang dùng

def generate_with_retry(prompt: str, max_retries=6):
    for attempt in range(max_retries):
        try:
            return client.models.generate_content(model=MODEL, contents=prompt)
        except Exception as e:
            msg = str(e)
            # Bắt lỗi 503 (high demand / unavailable)
            if "503" in msg or "UNAVAILABLE" in msg:
                sleep_s = min(30, (2 ** attempt)) + random.uniform(0, 0.5)
                print(f"Model busy (503). Retry in {sleep_s:.1f}s...")
                time.sleep(sleep_s)
                continue
            raise  # lỗi khác thì quăng ra luôn
    raise RuntimeError("Retry failed: model vẫn quá tải sau nhiều lần thử.")

resp = generate_with_retry("Hello")
print(resp.text)