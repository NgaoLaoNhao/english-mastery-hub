import sys, json, argparse
from google import genai

SYSTEM_INSTRUCTION = (
    "Bạn là trợ lý AI của ứng dụng English Mastery Hub — một ứng dụng quản lý "
    "việc học tiếng Anh theo nhóm. Luôn trả lời bằng tiếng Việt, ngắn gọn, "
    "thân thiện, sử dụng emoji phù hợp. Khi phân tích, hãy đưa ra gợi ý cụ thể."
)

def main():
    parser = argparse.ArgumentParser(description="Gemini AI Bridge for English Mastery Hub")
    parser.add_argument("--mode", choices=["warn", "analyze", "summarize", "chat"], required=True)
    parser.add_argument("--data", required=True)
    parser.add_argument("--api-key", required=True)
    args = parser.parse_args()

    client = genai.Client(api_key=args.api_key)
    MODEL = "gemini-2.0-flash"

    prompts = {
        "warn": (
            "Hãy viết 1 lời nhắc nhở hài hước bằng tiếng Việt cho thành viên "
            "chưa check-in học tiếng Anh. Giọng điệu thân thiện nhưng nghiêm khắc, "
            "có emoji, tối đa 3 câu. Khuyến khích họ quay lại học ngay. "
            f"Thông tin: {args.data}"
        ),
        "analyze": (
            "Phân tích tiến độ học tập tiếng Anh dựa trên dữ liệu check-in sau. "
            "Trả lời theo format:\n"
            "1. Điểm mạnh (1-2 dòng)\n"
            "2. Cần cải thiện (1-2 dòng)\n"
            "3. Lộ trình đề xuất ngày mai (Bookworm + Ministory, có giờ cụ thể)\n"
            "Sử dụng emoji phù hợp. "
            f"Dữ liệu: {args.data}"
        ),
        "summarize": (
            "Tóm tắt tài liệu học tiếng Anh sau. Trả lời theo format:\n"
            "1. Nội dung chính (2-3 bullet points)\n"
            "2. Từ vựng khó (3-5 từ, kèm phiên âm và nghĩa tiếng Việt)\n"
            "3. Ngữ pháp quan trọng (nếu có)\n"
            "Sử dụng emoji phù hợp. "
            f"Nội dung: {args.data}"
        ),
        "chat": SYSTEM_INSTRUCTION + "\n\nCâu hỏi: " + args.data,
    }

    try:
        response = client.models.generate_content(
            model=MODEL, contents=prompts[args.mode]
        )
        print(json.dumps({"ok": True, "text": response.text}, ensure_ascii=False))
    except Exception as e:
        error_msg = str(e)
        # Thông báo lỗi thân thiện hơn
        if "429" in error_msg or "RESOURCE_EXHAUSTED" in error_msg:
            error_msg = "⚠️ Đã hết lượt gọi AI miễn phí. Vui lòng thử lại sau 1 phút."
        elif "403" in error_msg or "PERMISSION_DENIED" in error_msg:
            error_msg = "🔑 API key không hợp lệ. Kiểm tra lại GEMINI_API_KEY."
        elif "503" in error_msg or "UNAVAILABLE" in error_msg:
            error_msg = "🔄 Server AI đang bận. Vui lòng thử lại sau vài giây."
        print(json.dumps({"ok": False, "error": error_msg}, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    main()
