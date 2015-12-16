# m.route.mode = 'pathname'
ores = m.prop "ores"
ores 0
time = m.prop "time"
time +new Date
workers = m.prop "workers"

#worker model
workers
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
v.last= +new Date for k,v of workers()

m.route document.body, '/',
  '/':
    view: ->
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
        m 'ul#workers',
          for k,v of workers()
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
  '/forge': ->
    view: ->
      m 'div.count', 'count'

last = time()
lp = (timestamp)->
  time +new Date
  for k,v of workers()
    delta = time() - v.last
    if delta > v.delta and v.cnt > 0
      # computation - reactive
      m.startComputation()
      ores ores()+v.ore*v.cnt * ~~(delta / v.delta)
      v.last = time()
      m.endComputation()
  window.requestAnimationFrame lp
window.requestAnimationFrame lp



