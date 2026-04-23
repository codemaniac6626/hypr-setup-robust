import webview
import os
import subprocess

class Api:
    def __init__(self):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.hypr_setup_dir = os.path.dirname(self.base_dir)

    def _get_folders(self, category):
        target_dir = os.path.join(self.hypr_setup_dir, category)
        try:
            folders = [f for f in os.listdir(target_dir) if os.path.isdir(os.path.join(target_dir, f))]
            return sorted(folders)
        except FileNotFoundError:
            return []

    def _get_current(self, category):
        current_file = os.path.join(self.hypr_setup_dir, category, 'current-theme')
        try:
            with open(current_file, 'r') as f:
                return f.read().strip()
        except FileNotFoundError:
            return ""

    def get_aesthetics(self):
        return self._get_folders('aesthetic')

    def get_functionals(self):
        return self._get_folders('functional')

    def get_current_aesthetic(self):
        return self._get_current('aesthetic')

    def get_current_functional(self):
        return self._get_current('functional')

    def apply_themes(self, aesthetic_name, functional_name):
        try:
            if aesthetic_name:
                aesthetic_script = os.path.join(self.hypr_setup_dir, 'aesthetic', 'apply-setup.sh')
                subprocess.run(['bash', aesthetic_script, aesthetic_name], check=True)
            
            if functional_name:
                functional_script = os.path.join(self.hypr_setup_dir, 'functional', 'apply-setup.sh')
                subprocess.run(['bash', functional_script, functional_name], check=True)
                
            return {"status": "success", "message": "Themes applied successfully!"}
        except subprocess.CalledProcessError as e:
            return {"status": "error", "message": f"Failed to apply theme: {str(e)}"}
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def save_theme(self, category, name):
        try:
            if not name or not name.strip():
                return {"status": "error", "message": "Theme name cannot be empty."}
            
            script_path = os.path.join(self.hypr_setup_dir, category, 'make-setup.sh')
            if not os.path.exists(script_path):
                return {"status": "error", "message": f"make-setup.sh not found for {category}."}
            
            subprocess.run(['bash', script_path, name.strip()], check=True)
            return {"status": "success", "message": f"Saved {category} theme: {name}"}
        except subprocess.CalledProcessError as e:
            return {"status": "error", "message": f"Failed to save {category} theme: {str(e)}"}
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def get_keybindings(self):
        current_func = self.get_current_functional()
        if not current_func:
            return []
        
        conf_path = os.path.join(self.hypr_setup_dir, 'functional', current_func, 'home', 'vs-horcrux', '.config', 'hypr', 'frags', 'keybindings.conf')
        if not os.path.exists(conf_path):
            return []
            
        bindings = []
        try:
            with open(conf_path, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line.startswith('bind =') or line.startswith('binde =') or line.startswith('bindm ='):
                        parts = line.split('#', 1)
                        comment = parts[1].strip() if len(parts) > 1 else ""
                        
                        bind_str = parts[0].strip()
                        if '=' in bind_str:
                            _, config = bind_str.split('=', 1)
                            args = [x.strip() for x in config.split(',')]
                            
                            if len(args) >= 3:
                                modifiers = args[0]
                                key = args[1]
                                action = args[2]
                                command = ",".join(args[3:]) if len(args) > 3 else ""
                                
                                bindings.append({
                                    "modifiers": modifiers,
                                    "key": key,
                                    "action": action,
                                    "command": command,
                                    "comment": comment
                                })
        except Exception as e:
            pass
        return bindings

    def close_app(self):
        if window:
            window.destroy()

if __name__ == '__main__':
    api = Api()
    html_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'web', 'index.html')
    
    # Create frameless window with transparency enabled
    window = webview.create_window(
        'Hyprland Themer', 
        html_path,
        js_api=api,
        width=800, 
        height=600,
        frameless=True,
        transparent=True,
        easy_drag=True,  # Enables easy dragging of frameless windows in pywebview
    )
    
    # webview.start(debug=True)
    webview.start()
