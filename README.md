<h1 align="center"><b>Sheas ◁ Cealer</b> | 配置生成器</h1>
<h3 align="center">- Just Ceal It -</h3>
<br>

## 自我介绍
**Sheas Cealer Hosts Generator**: 一只基于 **Bash 脚本**的 Sheas Cealer 配置生成器

## 使用方法
点击**Use this template**，按照指示设置仓库，然后修改 `Cealing-Source.txt` ，一行一个域名，推送后会自动触发生成，更新后的配置文件会自动推送到 **Releases** 中。

> [!NOTE]
> 若要设置自定义SNI，请在需要制定SNI的域名处使用 `DOMAIN:SNI` 格式（例：`pixiv.net:pixivision.net`）。
> 
> 可以使用 `#` 的注释语法。允许在条目后使用注释。

> [!WARNING]
> 暂不支持通配符，请手动指定所有可能的域名。

## 许可证
本项目采用 **GNU General Public License v3.0** 许可证。

详见 `LICENSE` 文件。