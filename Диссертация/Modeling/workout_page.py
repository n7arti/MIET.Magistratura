import tkinter as tk


def workout_page_content(workout_page, show_workout_page):
    button_frame = tk.Frame(workout_page)
    button_frame.pack(side=tk.BOTTOM, pady=50)
    buttonRepeat = tk.Button(button_frame, 
                       text="Повторить упражнение",
                       command=show_workout_page)
    buttonRepeat.pack(side=tk.LEFT, padx=5) 

    buttonNext = tk.Button(button_frame, 
                       text="Следующее упражнение",
                       command=show_workout_page)
    buttonNext.pack(side=tk.RIGHT, padx=5) 