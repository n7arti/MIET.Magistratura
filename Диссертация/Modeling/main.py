import tkinter as tk

from data_page import data_page_content
from workout_page import workout_page_content
from workout_setup_page import workout_setup_page_content


def full_window():
    # Получаем размеры экрана
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()

    # Устанавливаем размеры окна и его положение на полный экран
    root.geometry(f"{screen_width}x{screen_height}+0+0")
    
def save_data():
    show_workout_setup_page()
    
def show_workout_setup_page():
    data_page.pack_forget()
    workout_setup_page.pack(fill='both', expand=True)

def show_workout_page():
    workout_setup_page.pack_forget()
    workout_page.pack(fill='both', expand=True)


# Создаем основное окно
root = tk.Tk()
root.title("Составление тренировки с помощью математического моделирования движений")

# Создаем фрейм для первой страницы
data_page = tk.Frame(root)
workout_setup_page = tk.Frame(root)
workout_page = tk.Frame(root)

data_page.pack(fill='both', expand=True)

full_window()
data_page_content(data_page, save_data)
workout_setup_page_content(workout_setup_page, show_workout_page)
workout_page_content(workout_page, show_workout_setup_page)

# Запускаем цикл обработки событий
root.mainloop()