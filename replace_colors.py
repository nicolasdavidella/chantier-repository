import os
import re

lib_dir = "lib"

replacements = [
    (r"Color\(0xFF0F6E56\)", "AppColors.primary"),
    (r"Color\(0xFFD85A30\)", "AppColors.secondary"),
    (r"Color\(0xFF1A1A2E\)", "AppColors.textPrimaryLight"),
    (r"Color\(0xFFE8A838\)", "AppColors.warning"),
    (r"Color\(0xFFC94C3C\)", "AppColors.error"),
    (r"Color\(0xFFE5E7EB\)", "AppColors.borderLight"),
    (r"Color\(0xFFF6F7FB\)", "AppColors.backgroundLight"),
    (r"Color\(0xFFFAFAF8\)", "AppColors.backgroundLight"),
    (r"Color\(0xFF1E1E1E\)", "AppColors.backgroundDark"),
    (r"Color\(0xFF2C2C2C\)", "AppColors.surfaceDark"),
    
    (r"Colors\.red\.shade[0-9]+", "AppColors.error"),
    (r"Colors\.redAccent", "AppColors.error"),
    (r"Colors\.red\b", "AppColors.error"),
    
    (r"Colors\.green\.shade[0-9]+", "AppColors.success"),
    (r"Colors\.green\b", "AppColors.success"),
    
    (r"Colors\.orange\.shade[0-9]+", "AppColors.warning"),
    (r"Colors\.orangeAccent", "AppColors.warning"),
    (r"Colors\.orange\b", "AppColors.warning"),
    
    (r"Colors\.amber\.shade[0-9]+", "AppColors.warning"),
    (r"Colors\.amber\b", "AppColors.warning"),
    
    (r"Colors\.blue\.shade[0-9]+", "AppColors.primary"),
    (r"Colors\.blueAccent", "AppColors.primary"),
    (r"Colors\.blue\b", "AppColors.primary"),
    
    (r"Colors\.grey\.shade[0-9]+", "AppColors.textSecondaryLight"),
    (r"Colors\.grey\b", "AppColors.textSecondaryLight"),
    
    (r"Colors\.black\b", "AppColors.textPrimaryLight"),
]

import_statement = "import 'package:chantier_track/core/theme/app_colors.dart';\n"

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            if "app_colors.dart" in filepath or "app_theme.dart" in filepath:
                continue
                
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
                
            original_content = content
            needs_import = False
            
            for pattern, replacement in replacements:
                if re.search(pattern, content):
                    content = re.sub(pattern, replacement, content)
                    needs_import = True
            
            if needs_import and "app_colors.dart" not in content:
                import_matches = list(re.finditer(r"^import\s+['\"].*?['\"];$", content, re.MULTILINE))
                if import_matches:
                    last_import_pos = import_matches[-1].end()
                    content = content[:last_import_pos] + "\n" + import_statement + content[last_import_pos:]
                else:
                    content = import_statement + content
            
            if content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated {filepath}")
