![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg)

# What is Tiny Tapeout?

TinyTapeout is an educational project that aims to make it easier and cheaper than ever to get your digital designs manufactured on a real chip!

Go to https://tinytapeout.com for instructions!

## How to change the Wokwi project

Edit the [info.yaml](info.yaml) and change the wokwi_id to match your project.

## How to enable the GitHub actions to build the ASIC files

Please see the instructions for:

* [Enabling GitHub Actions](https://tinytapeout.com/faq/#when-i-commit-my-change-the-gds-action-isnt-running)
* [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

## How does it work?

When you edit the info.yaml to choose a different ID, the [GitHub Action](.github/workflows/gds.yaml) will fetch the digital netlist of your design from Wokwi.

After that, the action uses the open source ASIC tool called [OpenLane](https://www.zerotoasiccourse.com/terminology/openlane/) to build the files needed to fabricate an ASIC.

## Resources

* [FAQ](https://tinytapeout.com/faq/)
* [Digital design lessons](https://tinytapeout.com/digital_design/)
* [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
* [Join the community](https://discord.gg/rPK2nSjxy8)
* [Caravel](https://caravel-harness.readthedocs.io/en/latest/)

## Pin Assignments
| Signal      | Name                          | Dir | WCSP | QFN | PCB   |
|---          |---                            |---  |---   |---  |---    |
| mprj_io[0]  | JTAG                          | In  | D7   | 31  | J3.14 |
| mprj_io[1]  | SDO                           | Out | E9   | 32  | J3.13 |
| mprj_io[2]  | SDI                           | In  | F9   | 33  | J3.12 |
| mprj_io[3]  | CSB                           | In  | E8   | 34  | J3.11 |
| mprj_io[4]  | SCK                           | In  | F8   | 35  | J3.10 |
| mprj_io[5]  | SER_RX                        | In  | E7   | 36  | J3.9  |
| mprj_io[6]  | SER_TX                        | Out | F7   | 37  | J3.8  |
| mprj_io[7]  | IRQ                           | In  | E5   | 41  | J3.7  |
| mprj_io[8]  | DRIVER_SEL[0]                 | In  | F5   | 42  | J3.6  |
| mprj_io[9]  | DRIVER_SEL[1]                 | In  | E4   | 43  | J3.5  |
| mprj_io[10] | SLOW_CLK                      | Out | F4   | 44  | J3.4  |
| mprj_io[11] | SET_CLK_DIV                   | In  | E3   | 45  | J3.3  |
| mprj_io[12] | ACTIVE_SELECT[0]              | In  | F3   | 46  | J3.2  |
| mprj_io[13] | ACTIVE_SELECT[1]              | In  | D3   | 48  | J3.1  |
| mprj_io[14] | ACTIVE_SELECT[2]              | In  | E2   | 50  | J2.14 |
| mprj_io[15] | ACTIVE_SELECT[3]              | In  | F1   | 51  | J2.13 |
| mprj_io[16] | ACTIVE_SELECT[4]              | In  | E1   | 53  | J2.12 |
| mprj_io[17] | ACTIVE_SELECT[5]              | In  | D2   | 54  | J2.11 |
| mprj_io[18] | ACTIVE_SELECT[6]              | In  | D1   | 55  | J2.10 |
| mprj_io[19] | ACTIVE_SELECT[7]              | In  | C10  | 57  | J2.9  |
| mprj_io[20] | ACTIVE_SELECT[8]              | In  | C2   | 58  | J2.8  |
| mprj_io[21] | IO_IN[0] / EXT_SCAN_CLK_OUT   | In  | B1   | 59  | J2.7  |
| mprj_io[22] | IO_IN[1] / EXT_SCAN_DATA_OUT  | In  | B2   | 60  | J2.6  |
| mprj_io[23] | IO_IN[2] / EXT_SCAN_SELECT    | In  | A1   | 61  | J2.5  |
| mprj_io[24] | IO_IN[3] / EXT_SCAN_LATCH_EN  | In  | C3   | 62  | J2.4  |
| mprj_io[25] | IO_IN[4]                      | In  | A3   |  2  | J2.3  |
| mprj_io[26] | IO_IN[5]                      | In  | B4   |  3  | J2.2  |
| mprj_io[27] | IO_IN[6]                      | In  | A4   |  4  | J2.1  |
| mprj_io[28] | IO_IN[7]                      | In  | B5   |  5  | J1.14 |
| mprj_io[29] | IO_OUT[0] / EXT_SCAN_DATA_IN  | Out | A5   |  6  | J1.13 |
| mprj_io[30] | IO_OUT[1] / EXT_SCAN_DATA_IN  | Out | B6   |  7  | J1.12 |
| mprj_io[31] | IO_OUT[2]                     | Out | A6   |  8  | J1.11 |
| mprj_io[32] | IO_OUT[3]                     | Out | A7   | 11  | J1.10 |
| mprj_io[33] | IO_OUT[4]                     | Out | C8   | 12  | J1.9  |
| mprj_io[34] | IO_OUT[5]                     | Out | B8   | 13  | J1.4  |
| mprj_io[35] | IO_OUT[6]                     | Out | A8   | 14  | J1.3  |
| mprj_io[36] | IO_OUT[7]                     | Out | B9   | 15  | J1.2  |
| mprj_io[37] | READY                         | Out | A9   | 16  | J1.1  |
