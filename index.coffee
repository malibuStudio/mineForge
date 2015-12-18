# m.route.mode = 'pathname'
@ores = m.prop "ores"
ores 0
time = m.prop "time"
time +new Date
mine = m.prop "mine"

# mine model
mine
  miner:
    cnt: 0
    price: 100
    ore: 10
    delta: 2000
  cart:
    cnt: 0
    price: 1000
    ore: 100
    delta: 4000
v.last= +new Date for k,v of mine()

# forge model
@forge = [
  name: "knife"
  next: 300
  income: 100
  chance: 1
,
  name: "durk"
  next: 400
  income: 200
  chance: 1
,
  name: "mainGauche"
  next: 500
  income: 300
  chance: 1
,
  name: "shortSword"
  next: 700
  income: 400
  chance: 0.9
,
  name: "falchion"
  next: 1000
  income: 900
  chance: 0.85
,
  name: "blade"
  next: 1300
  income: 1400
  chance: 0.8
,
  name: "Mithril Sword"
  next: 200000
  income: 400000
  chance: 0.2
,
  name: "DEATH STAR!"
  next: 1000000000
  income: 1100000000
  chance: 0.01
]

forgeLevel = m.prop "forgeLevel"
forgeLevel 0

m.route document.body, '/',
  '/':
    view: ->
      m 'div#home',
        m 'h1', 'mineForge'
        m 'ul',
          m 'li',
            m 'a[href=/mine]', config:m.route, 'go to mine'
          m 'li',
            m 'a[href=/forge]', config:m.route, 'go to forge'
  '/mine':
    controller: ->
      't': -> time()
    view: (c)->
      m 'div#mine',
        m 'a[href=/]', config:m.route, '< back'
        m 'div#touchMine', onclick: (e)->
          ores ores()+1
          e.preventDefault()
        , 'mine'
        m 'ul#mine',
          for k,v of mine()
            m "li##{k}",
              m "span.name", k
              m "span.cnt", v.cnt
              # come closure!
              m "div.add", onclick: ((wrks)->
                (e)->
                  if ores()>=wrks.price
                    ores ores()-wrks.price
                    wrks.cnt += 1
                    wrks.last = +new Date
              )(v), "add"
              m "span.price", "price #{v.price} ore"
        m 'div#ores',
          m 'span.count', ores()
          m 'span', ' ores'
  '/forge':
    view: ->
      m 'div#forge',
        m 'a[href=/]', config:m.route, '< back'
        m 'div#equip'
          m 'h', "#{forge[forgeLevel()].name}"
          m 'div#ores',
            m 'span.count', ores()
            m 'span', ' ores'
          m 'div.info'
            m 'div.next', "next :#{forge[forgeLevel()].next}"
            m 'div.income', "income :#{forge[forgeLevel()].income}"
            m 'div.chance', "chance :#{forge[forgeLevel()].chance*100}%"
            m 'div.forge', onclick: (e)->
              unless ores()<forge[forgeLevel()].next
                chance = Math.random()
                ores ores()-forge[forgeLevel()].next
                if chance < forge[forgeLevel()].chance
                  ores ores()+forge[forgeLevel()].income
                  forgeLevel forgeLevel()+1
                else
                  forgeLevel 0
            , "forge!"

last = time()
lp = (timestamp)->
  time +new Date
  for k,v of mine()
    delta = time() - v.last
    if delta > v.delta and v.cnt > 0
      # computation - reactive
      m.startComputation()
      ores ores()+v.ore*v.cnt * ~~(delta / v.delta)
      v.last = time()
      m.endComputation()
  window.requestAnimationFrame lp
window.requestAnimationFrame lp
