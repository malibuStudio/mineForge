# m.route.mode = 'pathname'
ores = m.prop "ores"
# preserve ore counts by localStorage
ores +localStorage.getItem 'ores'
time = m.prop "time"
time +new Date
mine = m.prop "mine"

## mine model
mine
  miner:
    price: 100
    ore: 1
    delta: 50
  madMiner:
    price: 300
    ore: 1
    delta: 20
  cart:
    price: 1000
    ore: 10
    delta: 100
  train:
    price: 10000
    ore: 100
    delta: 200
# set initial value
getLastMineCount = (k,v)->
  try mineStorage = JSON.parse localStorage.getItem 'mine' catch e
    mineStorage = ''
  cnt = (mineStorage and mineStorage[k] and mineStorage[k].cnt) or 0
  last = (mineStorage and mineStorage[k] and mineStorage[k].last) or 0
  v.cnt = cnt
  v.last = last
setLastMineCount = ->
  r={}
  r[k]=cnt:v.cnt,last:v.last for k,v of mine()
  localStorage.setItem 'mine', JSON.stringify(r)
getLastMineCount k,v for k,v of mine()

## forge model
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
forgeLevel +localStorage.getItem 'forgeLevel'

# reset all statuses
resetAll = ->
  localStorage.clear()
  ores 0
  forgeLevel 0
  v.last= +new Date and v.cnt = 0 for k,v of mine()

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
    localStorage.setItem 'ores', +ores()
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
          m 'li',
            m 'span', onclick: ->
              resetAll()
            , "resetAll"
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
        m 'ul',
          for k,v of mine()
            m "li##{k}",
              m "div.name-count",
                m "span.name", k
                m "span.cnt", " #{v.cnt}ea"
              m "div.price", "price #{v.price} ore"
              m "div.delta", "speed #{v.delta} ore"
              # come closure!
              m "div.add", onclick: ((wrks)->
                ->
                  if ores()>=wrks.price
                    ores ores()-wrks.price
                    wrks.cnt += 1
                    wrks.last = +new Date
                    setLastMineCount()
              )(v), "add"
        currentOresComponent
  '/forge':
    view: ->
      f = forge[forgeLevel()]
      m 'div#forge',
        m 'a[href=/]', config:m.route, '< back'
        m 'div#equip'
          m 'h', "#{f.name}"
          currentOresComponent
          m 'div.info'
            m 'div.next', "next :#{f.next}"
            m 'div.chance', "chance :#{f.chance*100}%"
            m 'div.forge', onclick: ->
              unless ores()<f.next
                chance = Math.random()
                ores ores()-f.next
                if chance < f.chance
                  forgeLevel forgeLevel()+1
                else
                  forgeLevel 0
              localStorage.setItem 'forgeLevel', forgeLevel()
            , "forge!"

# infinite loop /w requestAnimationFrame
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
