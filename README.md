# Video Capture, Programmable Logic part
Устройство предназначено для захвата видео-сигнала с ретро-компьютеров и прочих утсройств, выдающих сигнал в форме, не принимаемой современными мониторами и преобразующее в нативный формат для конкретного монитора, подключенного в выходу устройства. Определение параметров отображения происходит автоматически посредством EDID через кабель VGA/DVI. Параметры захватываемого изображения определяются внешним МК (начало и ширина видимой области, полярность синхроимпульсов, режим смешивания цветовых сигналов).
## Аппаратные модули
- SPI master, Slave mux - отвечают за коммуникацию с управляющим МК посредством шины SPI;
- PLL cfg - конфигурируемый PLL, предназначенный для формирования выходного видеосигнала;
- SDRAM ctrl - контроллер памяти SDRAM, служащей фреймбуфером для транслируемого изображения;
- Stream cap - модуль захвата входного видеосигнала и его преобразования для дальнейшего отображения;
- Vedeo - формирование выходного видеосигнала.
## Конфигурационные регистры (LSB-to-MSB)
Video
| Address | Data |
| ------ | ------ |
|0x00| Horisontal active time( LSB, 8 bit) |
|0x01| Horisontal active time (MSB, 4 bit), Horisontal sync start (LSB, 4 bit)|
|0x02| Horisontal sync start (MSB, 8 bit)|
|0x03| Horisontal sync end ( LSB, 8 bit) |
|0x04| Horisontal sync end (MSB, 4 bit), Horisontal blank (LSB, 4 bit)|
|0x05| Horisontal blank (MSB, 8 bit)|
|0x06| Vertical active time( LSB, 8 bit) |
|0x07| Vertical active time (MSB, 4 bit), Vertical sync start (LSB, 4 bit)|
|0x08| Vertical sync start (MSB, 8 bit)|
|0x09| Vertical sync end ( LSB, 8 bit) |
|0x0a| Vertical sync end (MSB, 4 bit), Vertical blank (LSB, 4 bit)|
|0x0b| Vertical blank (MSB, 8 bit)|
|0x0c|Video active, DVI active, VGA active, Vertical sync polarity, Horisontal sync polarity|

PLL

| Address | Data |
| ------ | ------ |
|0x20| LFC (2 bit), LFR (5 bit), VCO (1 bit) |
|0x21|CP (2 bit), N odd (1 bit), N bypass (1 bit), M odd (1 bit), M bypass (1 bit), C0 odd (1 bit), C0 bypass (1 bit)|
|0x22|C1 odd (1 bit), C1 bypass (1 bit), C2 odd (1 bit), C2 bypass (1 bit), C3 odd (1 bit), C3 bypass (1 bit), C4 odd (1 bit), C4 bypass (1 bit)|
|0x23|N high|
|0x24|N low|
|0x25|M high|
|0x26|M low|
|0x27|C0 high|
|0x28|C0 low|
|0x29|C1 high|
|0x2a|C1 low|
|0x2b|C2 high|
|0x2c|C2 low|
|0x2d|C3 high|
|0x2e|C3 low|
|0x2f|C4 high|
|0x30|C4 low|

Stream capture

| Address | Data |
| ------ | ------ |
|0x40| X start( LSB, 8 bit) |
|0x41| X start (MSB, 4 bit), X size (LSB, 4 bit)|
|0x42| X size (MSB, 8 bit)|
|0x43| Y start ( LSB, 8 bit) |
|0x44| Y start (MSB, 4 bit), Y size (LSB, 4 bit)|
|0x45| Y size (MSB, 8 bit)|
|0x46| HS inverse (1 bit), VS inverse (1 bit), muxing mode (3 bit) |

