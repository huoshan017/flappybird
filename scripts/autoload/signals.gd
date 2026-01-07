extends Node

# 逻辑相关信号

# entity添加到场景树
signal entity_added_to_scene(entity: Entity)

# entity从场景树移除
signal entity_removed_from_scene(entity: Entity)

# 更新entity通知
signal entity_update(entity: Entity)

# 实体拍打通知
signal entity_flapped(entity: Entity)

# 实体碰撞通知
signal entity_collide(entity: Entity, collider: Entity)

# 实体死亡通知
signal entity_dead(entity: Entity)

# 进入游戏通知
signal enter_game()

# 重新進入游戏
signal re_enter_game()

# UI点击开始游戏
signal tap_play()

# 游戏开始
signal start_game()

# 暂停游戏
signal pause_game()

# 游戏结束前
signal before_game_over()

# 游戏结束
signal game_over()