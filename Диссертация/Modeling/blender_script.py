import bpy

# Очистить текущую анимацию
bpy.context.scene.frame_set(0)
for fc in bpy.data.objects['Armature'].animation_data.action.fcurves:
    fc.keyframe_points.clear()

# Пример установки позы для арматуры на кадре 1
bpy.context.scene.frame_set(1)
bpy.data.objects['Armature'].pose.bones['Bone'].location = (1, 0, 0)
bpy.data.objects['Armature'].pose.bones['Bone'].keyframe_insert(data_path="location", frame=1)

# Пример установки другой позы для арматуры на кадре 10
bpy.context.scene.frame_set(10)
bpy.data.objects['Armature'].pose.bones['Bone'].location = (2, 0, 0)
bpy.data.objects['Armature'].pose.bones['Bone'].keyframe_insert(data_path="location", frame=10)

# Сохранить сцену (если необходимо)
# bpy.ops.wm.save_mainfile(filepath="path_to_save.blend")