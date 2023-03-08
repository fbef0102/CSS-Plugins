# Description | 內容
Allows players to be respawned at one's crosshair.

* Video | 影片展示
<br/>None

* Image | 圖示
	* Say !admin -> Player commands -> Respawn Player
		> 示範
		<br/>![css_respawn_player_1](image/css_respawn_player_1.gif)

* Apply to | 適用於
	```
	CSS
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.1 (2023-3-8)
		* Give Kevlar Suit and a Helmet when repsawn player

	* v1.0 (2023-3-3)
		* Initial Release
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/css_respawn_player.cfg
		```php
		// If 1, Add 'Respawn player' item in admin menu under 'Player commands' category
		css_respawn_player_adminmenu "1"

		// If 1, Give Kevlar Suit and a Helmet when repsawn player
		css_respawn_player_armor "1"

		// After respawn player, teleport player to 0=Crosshair, 1=Self (You must be alive).
		css_respawn_player_destination "0"

		// Respawn players with this loadout, separate by commas
		css_respawn_player_loadout "weapon_knife,weapon_glock,weapon_mp5navy"

		// If 1, Notify in chat and log action about respawn?
		css_respawn_player_showaction "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Respawn a player at your crosshair. Without argument - opens menu to select players (Adm required: ADMFLAG_BAN)**
		```php
		sm_respawn
		```
</details>

- - - -
# 中文說明
復活死亡的玩家並傳送

* 原理
	* 管理員輸入!respawn 可以復活指定的死亡玩家並傳送到準心上

* 功能
	* 可以加入到管理員菜單下，輸入!admin->玩家指令->復活玩家
	* 可設置復活後給予的武器
	* 可設置是否給防彈背心與頭盔
	* 紀錄log