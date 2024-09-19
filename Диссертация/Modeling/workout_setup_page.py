import tkinter as tk

from setup_blend import start_blender_animation


def workout_setup_page_content(workout_setup_page, show_workout_page):
    button = tk.Button(
        workout_setup_page, 
        text="Составить тренировку", 
        command=start_blender_animation)
    button.pack(side=tk.BOTTOM, pady=50) 