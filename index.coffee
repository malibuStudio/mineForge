# m.route.mode = 'pathname'
ores = m.prop "ores"
ores 0
time = m.prop "time"
time +new Date
mine = m.prop "mine"

# mine model
mine
  miner:
    cnt: 0
    price: 100
    ore: 1
    delta: 50
  madMiner:
    cnt: 0
    price: 300
    ore: 1
    delta: 20
  cart:
    cnt: 0
    price: 1000
    ore: 10
    delta: 100
  train:
    cnt: 0
    price: 10000
    ore: 100
    delta: 200
v.last= +new Date for k,v of mine()

# forge model
forge = [
  name: "knife"
  next: 300
  chance: 1
,
  name: "durk"
  next: 400
  chance: 1
,
  name: "mainGauche"
  next: 500
  chance: 1
,
  name: "shortSword"
  next: 700
  chance: 0.9
,
  name: "falchion"
  next: 1000
  chance: 0.85
,
  name: "blade"
  next: 1300
  chance: 0.8
,
  name: "Mithril Sword"
  next: 200000
  chance: 0.2
,
  name: "DEATH STAR!"
  next: 1000000000
  chance: 0.01
]

forgeLevel = m.prop "forgeLevel"
forgeLevel 0

# easter egg
eggBuf=""
sesame="rhwlqheld"

document.addEventListener 'keypress', (e)->
  eggBuf += String.fromCharCode(e.charCode)
  eggBuf = eggBuf.substring(eggBuf.length-sesame.length)
  m.startComputation()
  ores ores()*10 if eggBuf is sesame
  m.endComputation()

# components
currentOresComponent = m.component
  view: ->
    m 'div#ores',
      m 'span.count', ores()
      m 'span', ' ores'

# main Router
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
        currentOresComponent
  '/mine':
    controller: ->
      't': -> time()
    view: ->
      m 'div#mine',
        m 'a[href=/]', config:m.route, '< back'
        m 'div#touchMine', onclick: ->
          ores ores()+1
        ,'mine'
        m 'ul#mine',
          for k,v of mine()
            m "li##{k}",
              m "span.name", k
              m "span.cnt", v.cnt
              # come closure!
              m "div.add", onclick: ((wrks)->
                ->
                  if ores()>=wrks.price
                    ores ores()-wrks.price
                    wrks.cnt += 1
                    wrks.last = +new Date
              )(v), "add"
              m "span.price", "price #{v.price} ore"
        currentOresComponent
  '/forge':
    view: ->
      m 'div#forge',
        m 'a[href=/]', config:m.route, '< back'
        m 'div#equip'
          m 'h', "#{forge[forgeLevel()].name}"
          currentOresComponent
          m 'div.info'
            m 'div.next', "next :#{forge[forgeLevel()].next}"
            m 'div.chance', "chance :#{forge[forgeLevel()].chance*100}%"
            m 'div.forge', onclick: ->
              unless ores()<forge[forgeLevel()].next
                chance = Math.random()
                ores ores()-forge[forgeLevel()].next
                if chance < forge[forgeLevel()].chance
                  forgeLevel forgeLevel()+1
                else
                  forgeLevel 0
            , "forge!"

lp = ->
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
