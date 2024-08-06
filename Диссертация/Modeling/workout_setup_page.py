import tkinter as tk


def workout_setup_page_content(workout_setup_page, show_workout_page):
    button = tk.Button(
        workout_setup_page, 
        text="Составить тренировку", 
        command=show_workout_page)
    button.pack(side=tk.BOTTOM, pady=50) 