import os
import re

lib_dir = "lib"

# Fix patterns: Colors.grey[N] -> AppColors.greyN, AppColors.xxx[N] -> AppColors.greyN or equivalent
# bracket_replacements[pattern] = replacement
bracket_replacements = [
    # AppColors.textSecondaryLight[N] -> closest named shade
    (r"AppColors\.textSecondaryLight\[700\]", "AppColors.grey700"),
    (r"AppColors\.textSecondaryLight\[600\]", "AppColors.grey600"),
    (r"AppColors\.textSecondaryLight\[500\]", "AppColors.grey500"),
    (r"AppColors\.textSecondaryLight\[400\]", "AppColors.grey400"),
    (r"AppColors\.textSecondaryLight\[300\]!", "AppColors.grey300"),
    (r"AppColors\.textSecondaryLight\[300\]", "AppColors.grey300"),
    (r"AppColors\.textSecondaryLight\[200\]!", "AppColors.grey200"),
    (r"AppColors\.textSecondaryLight\[200\]", "AppColors.grey200"),
    (r"AppColors\.textSecondaryLight\[100\]", "AppColors.grey100"),
    (r"AppColors\.textSecondaryLight\[50\]", "AppColors.grey100"),
    # AppColors.success[N]
    (r"AppColors\.success\[700\]!", "AppColors.successDark"),
    (r"AppColors\.success\[700\]", "AppColors.successDark"),
    (r"AppColors\.success\[300\]!", "AppColors.successVariant"),
    (r"AppColors\.success\[300\]", "AppColors.successVariant"),
    (r"AppColors\.success\[200\]!", "AppColors.successLight"),
    (r"AppColors\.success\[200\]", "AppColors.successLight"),
    # AppColors.primary[N]
    (r"AppColors\.primary\[200\]!", "AppColors.primaryLight"),
    (r"AppColors\.primary\[200\]", "AppColors.primaryLight"),
    (r"AppColors\.primary\[700\]!", "AppColors.primaryDark"),
    (r"AppColors\.primary\[700\]", "AppColors.primaryDark"),
    # AppColors.warning[N]
    (r"AppColors\.warning\[200\]!", "AppColors.warningLight"),
    (r"AppColors\.warning\[200\]", "AppColors.warningLight"),
    (r"AppColors\.warning\[700\]!", "AppColors.warningDark"),
    (r"AppColors\.warning\[700\]", "AppColors.warningDark"),
    # AppColors.error[N]
    (r"AppColors\.error\[200\]!", "AppColors.errorLight"),
    (r"AppColors\.error\[200\]", "AppColors.errorLight"),
    # PdfAppColors -> use pdf colors
    (r"PdfAppColors\.textSecondaryLight", "PdfColor(0x6B, 0x6B, 0x63)"),
    (r"PdfAppColors\.textPrimaryLight", "PdfColor(0x1A, 0x1A, 0x1A)"),
    (r"PdfAppColors\.primary", "PdfColor(0x0F, 0x6E, 0x56)"),
    (r"PdfAppColors\.secondary", "PdfColor(0xD8, 0x5A, 0x30)"),
    (r"PdfAppColors\.borderLight", "PdfColor(0xEB, 0xEB, 0xE6)"),
]

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
            original = content
            for pattern, replacement in bracket_replacements:
                content = re.sub(pattern, replacement, content)
            if content != original:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(content)
                print(f"Fixed: {filepath}")
