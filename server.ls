require! <[express mongodb passport passport-local passport-facebook body-parser express-session]>

user = {}

# basic mongodb and express setup
mongodb.MongoClient.connect "mongodb://localhost/passport", (e, db) ->
  db.collection \user, (e, c) -> user <<< {db, c}
app = express!
api = express.Router!
app.use body-parser.json!
app.use body-parser.urlencoded extended: true
app.set 'view engine', 'jade'

# 1. strategy: local and facebook
passport.use new passport-local.Strategy (u,p,done) -> 
  if not (u == \tkirby and p == \1234) => done null, false
  done null, {id: 1}
passport.use new passport-facebook.Strategy(
  do
    clientID: \252332158147402
    clientSecret: \763c2bf3a2a48f4d1ae0c6fdc2795ce6
    callbackURL: "http://localhost/api/auth/facebook/callback"
  , (access-token, refresh-token, profile, done) ->
    done null, profile
)

# 2. middleware
app.use express-session secret: \tkirbyshandsome, resave: false, saveUninitialized: false
app.use passport.initialize!
app.use passport.session!

# 3. session
passport.serializeUser (u,done) -> done null, JSON.stringify(u)
passport.deserializeUser (v,done) -> done null, JSON.parse(v)

# 4. form and route
app.use \/api, api
api.get \/, (req, res) -> res.render \index
api.get \/login, (req, res) -> res.render \login
api.get \/logout, (req, res) -> 
  if req.user => req.logout!
  res.redirect \/login
api.get \/done, (req, res) -> res.render \done, req.user # 取得使用者
api.get \/fail, (req, res) -> res.render \fail
api.get \/admin, (req, res) ->
  if !req.user => return res.status(403).send()
  res.render \admin, req.user
api.post \/login, passport.authenticate \local, do
  successRedirect: \/api/done
  failureRedirect: \/api/fail

api.get \/auth/facebook, passport.authenticate \facebook
api.get \/auth/facebook/callback, passport.authenticate \facebook, do
  successRedirect: \/api/done
  failureRedirect: \/api/fail

server = app.listen 9000, -> console.log "listening on port #{server.address!port}"
