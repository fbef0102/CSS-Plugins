# Description | 內容
Teleport an alive player in game

* Video | 影片展示
<br/>None

* Image | 圖示
	* Say !admin -> Player commands -> Teleport Player
		> 示範
		<br/>![css_teleport_player_1](image/css_teleport_player_1.gif)

* Apply to | 適用於
	```
	CSS
	```

* Translation Support | 支援翻譯
	```
	English
	繁體中文
	简体中文
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0 (2023-3-3)
		* Initial Release
</details>

* Require | 必要安裝
<br/>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/css_teleport_player.cfg
		```php
		// If 1, Add 'Teleport player' item in admin menu under 'Player commands' category
		css_teleport_playeradminmenu "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Open 'Teleport player' menu (Adm required: ADMFLAG_BAN)**
		```php
		sm_teleport
		sm_tp
		```
</details>

- - - -
# 中文說明
傳送玩家到其他玩家身上或準心上

* 原理
	* 管理員輸入!teleport 可以傳送指定玩家到準心上或是其他玩家身上

* 功能
	* 可以加入到管理員菜單下，輸入!admin->玩家指令->傳送玩家