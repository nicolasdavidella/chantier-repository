import os
import re

lib_dir = "lib"

# ALL patterns to fix
patterns = [
    # 1. Remove "const " before AppColors.xxx (not a constructor call)
    (r"\bconst AppColors\.", "AppColors."),

    # 2. bracket indexing on Color types -> named constants
    (r"AppColors\.textSecondaryLight\[700\]!?", "AppColors.grey700"),
    (r"AppColors\.textSecondaryLight\[600\]!?", "AppColors.grey600"),
    (r"AppColors\.textSecondaryLight\[500\]!?", "AppColors.grey500"),
    (r"AppColors\.textSecondaryLight\[400\]!?", "AppColors.grey400"),
    (r"AppColors\.textSecondaryLight\[300\]!?", "AppColors.grey300"),
    (r"AppColors\.textSecondaryLight\[200\]!?", "AppColors.grey200"),
    (r"AppColors\.textSecondaryLight\[100\]!?", "AppColors.grey100"),
    (r"AppColors\.textSecondaryLight\[50\]!?",  "AppColors.grey100"),
    (r"AppColors\.success\[700\]!?",   "AppColors.successDark"),
    (r"AppColors\.success\[300\]!?",   "AppColors.successVariant"),
    (r"AppColors\.success\[200\]!?",   "AppColors.successLight"),
    (r"AppColors\.success\[100\]!?",   "AppColors.successLight"),
    (r"AppColors\.primary\[900\]!?",   "AppColors.primaryDark"),
    (r"AppColors\.primary\[700\]!?",   "AppColors.primaryDark"),
    (r"AppColors\.primary\[200\]!?",   "AppColors.primaryLight"),
    (r"AppColors\.primary\[100\]!?",   "AppColors.primaryLight"),
    (r"AppColors\.warning\[700\]!?",   "AppColors.warningDark"),
    (r"AppColors\.warning\[200\]!?",   "AppColors.warningLight"),
    (r"AppColors\.warning\[100\]!?",   "AppColors.warningLight"),
    (r"AppColors\.error\[700\]!?",     "AppColors.error"),
    (r"AppColors\.error\[200\]!?",     "AppColors.errorLight"),
    (r"AppColors\.error\[100\]!?",     "AppColors.errorLight"),
    (r"AppColors\.secondary\[700\]!?", "AppColors.secondaryDark"),
    (r"AppColors\.secondary\[200\]!?", "AppColors.secondaryLight"),
    (r"AppColors\.info\[700\]!?",      "AppColors.info"),
    (r"AppColors\.info\[200\]!?",      "AppColors.infoLight"),

    # 3. PdfAppColors -> hardcoded PdfColor values
    (r"PdfAppColors\.textSecondaryLight", "PdfColor(0x6B, 0x6B, 0x63)"),
    (r"PdfAppColors\.textPrimaryLight",   "PdfColor(0x1A, 0x1A, 0x1A)"),
    (r"PdfAppColors\.primary",            "PdfColor(0x0F, 0x6E, 0x56)"),
    (r"PdfAppColors\.secondary",          "PdfColor(0xD8, 0x5A, 0x30)"),
    (r"PdfAppColors\.borderLight",        "PdfColor(0xEB, 0xEB, 0xE6)"),
    (r"PdfAppColors\.[a-zA-Z]+",          "PdfColors.grey500"),

    # 4. AppColors.primary.withValues -> AppColors.primary.withAlpha or handle it
    # withValues is fine for Color, leave it
]

changed_files = []
for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            if "app_colors.dart" in filepath:
                continue
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
            original = content
            for pattern, replacement in patterns:
                content = re.sub(pattern, replacement, content)
            if content != original:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(content)
                changed_files.append(filepath)
                print(f"Fixed: {filepath}")

print(f"\nTotal files fixed: {len(changed_files)}")
