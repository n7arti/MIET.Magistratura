import tkinter as tk


def draw_human_skeleton(canvas):
    # # Тело и голова
    canvas.create_line(150, 70, 150, 150, width=5)   # Шея
    canvas.create_oval(130, 20, 170, 70, width=5,)      # Голова
    canvas.create_line(150, 150, 150, 300, width=5)  # Тело

    # # Руки
    canvas.create_line(150, 100, 100, 120, width=5)   # Правое надплечье
    canvas.create_line(150, 100, 200, 120, width=5)   # Левое надплечье

    canvas.create_line(100, 120, 70, 200, width=5)    # Правое плечо
    canvas.create_line(200, 120, 230, 200, width=5)    # Левое плечо

    canvas.create_line(70, 200, 50, 310, width=5)    # Правое предплечье
    canvas.create_line(230, 200, 250, 310, width=5)    # Левое предплечье

    canvas.create_line(50, 310, 60, 330, width=5)    # Правая кисть
    canvas.create_line(250, 310, 240, 330, width=5)    # Левая кисть

    # Ноги
    canvas.create_line(150, 300, 120, 340, width=5)    # Правая часть таза
    canvas.create_line(150, 300, 180, 340, width=5)    # Левая часть таза

    canvas.create_line(120, 340, 100, 400, width=5)    # Правое бедро
    canvas.create_line(180, 340, 200, 400, width=5)    # Левое бедро

    canvas.create_line(100, 400, 90, 500, width=5)    # Правая голень
    canvas.create_line(200, 400, 210, 500, width=5)    # Левая голень

    canvas.create_line(90, 500, 50, 520, width=5)    # Правая стопа
    canvas.create_line(210, 500, 250, 520, width=5)    # Левая стопа

    # Суставы
    joints = {
        "neck": (150, 100), # Шея
        "hip": (150, 300), # Таз
        "rightshoulder": (100, 120), # Правое плечо
        "leftshoulder": (200, 120), # Левое плечо
        "rightelbow": (70, 200), # Правый локоть
        "leftelbow": (230, 200), # Левый локоть
        "rightwrist": (50, 310), # Правая кисть
        "leftwrist": (250, 310), # Левая кисть
        "righthip": (120, 340), # Правый тазобедренный
        "lefthip": (180, 340), # Левый тазобедренный
        "leftknee": (100, 400), # Правое колено
        "rightknee": (200, 400), # Левое колено
        "rightankle": (90, 500), # Правый голеностоп
        "leftankle": (210, 500), # Левый голеностоп
    }

    # Нарисуем суставы
    for joint, (x, y) in joints.items():
        canvas.create_oval(x-5, y-5, x+5, y+5, fill='red')

def data_page_content(data_page, save_data):
    # Создаем кнопку "Сохранить"
    button = tk.Button(data_page, text="Сохранить", command=save_data)
    button.pack(side=tk.BOTTOM, pady=50) 

    canvas = tk.Canvas(data_page, width=300, height=800)
    canvas.pack()

    # Рисуем силуэт человека с суставами
    draw_human_skeleton(canvas)