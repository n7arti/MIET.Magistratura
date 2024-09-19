import subprocess

def start_blender_animation():
    # Путь к Blender
    blender_path = "C:/Program Files/Blender Foundation/Blender 4.1/blender.exe"
    # Путь к сцене Blender
    scene_path = "D:/Учеба/MIET.Magistratura/Диссертация/Modeling/human.blend"
    # Путь к скрипту, который запускает анимацию
    script_path = "D:/Учеба/MIET.Magistratura/Диссертация/Modeling/blender_script.py"

    # Запуск Blender с параметрами
    subprocess.run([blender_path, scene_path, "--python", script_path])