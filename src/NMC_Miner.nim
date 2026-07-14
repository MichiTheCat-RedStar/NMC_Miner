#       NMC_Miner // ☭
# MichiTheCat-RedStar (c) 2026

from std/rdstdin import readLineFromStdin
from std/unicode import toLower
from std/strutils import strip, formatFloat, ffDecimal
from std/os import sleep, fileExists
from std/random import rand, randomize
import std/json

const VERSION = "v1.1c"

var
  NMC: float = 0      # Деньги пользователя
  steps: int = 0      # Сколько циклов прошёл пользователь
  NMC_all: float = 0  # Сколько всего заработал пользователь

type ShopObjects = enum # Товары в магазине
  InitShop, MoreSpeed, Autosave, Autoload
var Shop: array[ShopObjects, bool] = [false, false, false, false]

#[ TODO: Шпаргалка для будущего
  Ну я тут и накрутил для будущей обновы магазина... Так извернуться...
  Теперь к объектам можно образаться как Shop[MoreSpeed] и прочее
  
  Расшифровки:
    InitShop - нужно купить сам магазин, чтобы получить к нему доступ
    MoreSpeed - быстрее работает cycle за счёт сокращения rand в sleep
    Autosave и Autoload понятны из названия
]#

let help = """
help|h|?  - Помощь
balance|b - Посмотреть свой баланс
info|i    - Посмотреть полную информацию
start|s   - Начать выполнение цикла
exit|e    - Выйти
save|m+   - Сохранить
load|m-   - Загрузить"""

proc save(): void =
  let data = %*{"NMC": NMC, "steps": steps, "NMC_all": NMC_all}
  writeFile("save.json", $pretty(data))

proc load(): JsonNode =
  if fileExists("save.json"):
    try:
      return parseFile("save.json")
    except JsonParsingError:
      return %*{"NMC": 0, "steps": 0, "NMC_all": 0}
  else:
    return %*{"NMC": 0, "steps": 0, "NMC_all": 0}

proc cycle(): float =
  let all_steps: int = rand(10 .. 5000)
  for step in 1 .. all_steps:
    write(stdout, "\rЗагрузка... [" & $step & "/" & $all_steps & "]")
    flushFile(stdout)
    sleep(rand(1 .. 100))
  echo ""
  return rand(0.1 .. 1.0)

randomize()
echo "NMC_Miner - MichiTheCat-RedStar (c) 2026 | Версия: ", VERSION, "\nВведите 'help' для помощи"
while true:
  echo "" # Исправляет ошибку с Backspace для UTF-8
  let input = readLineFromStdin(">>> ").strip().toLower()
  case input
  of "help", "h", "?":
    echo help
  of "balance", "b":
    echo "Ваш баланс: ", formatFloat(NMC, ffDecimal, 2), " NMC"
  of "info", "i":
    echo "Ваш баланс: ", NMC, " NMC\nЗаработано всго: ", NMC_all, " NMC\nВсего циклов: ", steps
    if (steps != 0) and (NMC_all != 0.0):
      echo "Среднее количество заработка за цикл: ", formatFloat(NMC_all/float(steps), ffDecimal, 2)
  of "start", "s":
    echo "Запущен рассчёт цикла:"
    let data = cycle()
    NMC += data
    NMC_all += data
    steps += 1
    echo "Счёт пополнен на ", data, " NMC"
  of "exit", "e":
    echo "Спасибо, что играли в NMC_Miner!"
    break
  of "save", "m+":
    save()
    echo "Успешно сохранено!"
  of "load", "m-":
    let data = load()
    NMC = data["NMC"].getFloat()
    steps = data["steps"].getInt()
    NMC_all = data["NMC_all"].getFloat()
    if NMC == 0 and steps == 0 and NMC_all == 0:
      echo "Файл пустой или повреждён"
    else:
      echo "Успешно загружено!"
  of "":
    discard
  else:
    echo "Неизвестная команда: \"", input, "\""

#[
  Прошу поддержки на бусти, буду благодарен: link =
    https://boosty.to/michithecat_redstar/posts/3a003ca9-8453-42cc-9473-dacd84a789e1?share=post_link
]#
