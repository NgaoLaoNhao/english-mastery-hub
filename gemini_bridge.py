import sys, json, argparse
from google import genai

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["warn", "analyze", "summarize", "chat"], required=True)
    parser.add_argument("--data", required=True)
    parser.add_argument("--api-key", required=True)
    args = parser.parse_args()

    client = genai.Client(api_key=args.api_key)
    MODEL = "gemini-2.0-flash"

    prompts = {
        "warn": (
            "Hãy viết 1 lời nhắc nhở hài hước bằng tiếng Việt, "
            "giọng điệu thân thiện nhưng nghiêm khắc, tối đa 2 câu. "
            f"Thông tin: {args.data}"
        ),
        "analyze": (
            "Phân tích tiến độ học tập tiếng Anh dựa trên dữ liệu sau "
            "và đề xuất lộ trình ngày mai (Bookworm + Ministory). "
            f"Dữ liệu: {args.data}"
        ),
        "summarize": (
            "Tóm tắt tài liệu tiếng Anh sau, trích xuất từ vựng khó "
            "và giải thích ngữ pháp quan trọng. "
            f"Nội dung: {args.data}"
        ),
        "chat": args.data,
    }

    try:
        response = client.models.generate_content(
            model=MODEL, contents=prompts[args.mode]
        )
        print(json.dumps({"ok": True, "text": response.text}, ensure_ascii=False))
    except Exception as e:
        print(json.dumps({"ok": False, "error": str(e)}, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    main()
