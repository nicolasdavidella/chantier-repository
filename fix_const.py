import os
import re

lib_dir = "lib"

# Fix "const AppColors.xxx" -> "AppColors.xxx"  (AppColors statics are const, but cant use "const ClassName.field" syntax)
# Also fix "Colors.xxx" that are actually "AppColors.xxx" (leftover from the Python pass which added "Colors." prefix by mistake)

patterns = [
    (r"const AppColors\.", "AppColors."),
]

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
            original = content
            for pattern, replacement in patterns:
                content = re.sub(pattern, replacement, content)
            if content != original:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(content)
                print(f"Fixed: {filepath}")
