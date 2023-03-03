
# Description | 內容
Player can drop knife and HE Grenade, Smoke Grenade, Flash Bang

* Video | 影片展示
<br/>None

* Image | 圖示
    * Drop all weapons and items
        > 丟出所有武器與物品
		<br/>![css_drop_weapon_1](image/css_drop_weapon_1.gif)

* Apply to | 適用於
    ```
    CSS
    ```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0 (2023-3-3)
		* Initial Release
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\css_drop_weapon.cfg
		```php
        // If 1, allow player to drop flash bang
        css_drop_weapon_drop_flashbang "1"

        // If 1, allow player to drop fragmentation grenades
        css_drop_weapon_drop_hegrenade "1"

        // If 1, allow player to drop knife
        css_drop_weapon_drop_knife "0"

        // If 1, allow player to drop smoke grenades
        css_drop_weapon_drop_smokegrenade "1"

        // 0=Plugin off, 1=Plugin on.
        css_drop_weapon_enable "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

- - - -
# 中文說明
可以丟棄手中的刀、閃光彈、高爆手榴彈、煙霧彈

* 原理
    * 按下"丟棄手中的物品"按鍵時，丟棄任何武器
    * 攜帶多個閃光彈、高爆手榴彈、煙霧彈時也可丟棄
    * 當扔出投閃光彈、高爆手榴彈、煙霧彈時，不能丟棄
    * 當使用刀進行攻擊動作時，不能丟棄

* 功能
    * 可設置刀子是否能丟棄
    * 可設置閃光彈是否能丟棄
    * 可設置高爆手榴彈是否能丟棄
    * 可設置煙霧彈是否能丟棄



