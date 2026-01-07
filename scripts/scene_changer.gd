extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rect: ColorRect = $ColorRect

func sleep(time: float):
    await get_tree().create_timer(time).timeout

func play_fade(task: Callable) -> void:
    rect.mouse_filter = Control.MOUSE_FILTER_STOP

    # 1. 变黑
    animation_player.play("fade")
    await animation_player.animation_finished

    # 2. 执行传进来的任务(可能是切换UI，或者是实例化新地图)
    if task.is_valid():
        await task.call()

    # 3. 变亮
    animation_player.play_backwards("fade")
    await animation_player.animation_finished

    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE