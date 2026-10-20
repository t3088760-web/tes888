-- =====================================================
-- DEEP VALIDATOR SCANNER - ULTIMATE EDITION
-- [แยก 2 ระบบ: เจาะ=เช็ค BlockedIDs / เปิดตาม=ไม่เช็ค]
-- [แก้ไข: รองรับการเปิดเพลงทั้ง Boombox และ Scooter พร้อมกัน]
-- =====================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CurrentSelectedPlayer = nil
local StatusLabel = nil

local AssetCache = {}

-- ==================== ระบบบันทึก ====================
local SavedSongs = {}
local SAVE_FILE_NAME = "WIN84_SavedSongs.json"
local OLD_SAVE_FILES = { "HONKUKI_SavedSongs.json", "DEEP_SavedSongs.json", "SavedSongs.json" }

local function saveSavedSongs()
    if writefile then
        pcall(function() writefile(SAVE_FILE_NAME, HttpService:JSONEncode(SavedSongs)) end)
    end
end

local function loadSavedSongs()
    SavedSongs = {}
    local loadedMap = {}
    local function parseAndMerge(fileContent)
        local success, data = pcall(function() return HttpService:JSONDecode(fileContent) end)
        if success and type(data) == "table" then
            for _, item in ipairs(data) do
                local songId, songName = nil, nil
                if type(item) == "string" then
                    songId = item
                    songName = "เพลงที่ " .. (#SavedSongs + 1)
                elseif type(item) == "table" and item.id then
                    songId = tostring(item.id)
                    songName = item.name or ("เพลงที่ " .. (#SavedSongs + 1))
                end
                if songId and not loadedMap[songId] then
                    loadedMap[songId] = true
                    table.insert(SavedSongs, { id = songId, name = songName })
                end
            end
        end
    end
    if readfile and isfile and isfile(SAVE_FILE_NAME) then parseAndMerge(readfile(SAVE_FILE_NAME)) end
    if readfile and isfile then
        for _, oldFile in ipairs(OLD_SAVE_FILES) do
            if isfile(oldFile) then parseAndMerge(readfile(oldFile)) end
        end
    end
    saveSavedSongs()
end

local function addSavedSong(songId, customName)
    if not songId or songId == "" then return false end
    songId = tostring(songId)
    for _, song in ipairs(SavedSongs) do
        if song.id == songId then return false end
    end
    table.insert(SavedSongs, { id = songId, name = customName or ("เพลงที่ " .. (#SavedSongs + 1)) })
    saveSavedSongs()
    return true
end

local function removeSavedSong(songId)
    songId = tostring(songId)
    for i, song in ipairs(SavedSongs) do
        if song.id == songId then
            table.remove(SavedSongs, i)
            saveSavedSongs()
            return true
        end
    end
    return false
end

local function updateSongName(songId, newName)
    songId = tostring(songId)
    for _, song in ipairs(SavedSongs) do
        if song.id == songId then
            song.name = newName
            saveSavedSongs()
            return true
        end
    end
    return false
end

loadSavedSongs()

-- ==================== บล็อค ID ปลอม (สำหรับปุ่มเจาะเท่านั้น) ====================
local BlockedIDs = {
    ["00106800577264015"] = true, ["00109462618039650"] = true, ["00112583972042063"] = true,
    ["00113841533670628"] = true, ["00116872955970254"] = true, ["00117424747387525"] = true,
    ["00117628371363749"] = true, ["00121320825772761"] = true, ["00125329595131078"] = true,
    ["00129043827992035"] = true, ["00134076916421685"] = true, ["00134523838494464"] = true,
    ["00137058099826867"] = true, ["00138763959207625"] = true, ["0070567654933546"] = true,
    ["0079688020178596"] = true, ["0083260119948695"] = true, ["0083681471562121"] = true,
    ["0083848201981900"] = true, ["0090308298517537"] = true, ["0093338918256962"] = true,
    ["0093932829347443"] = true, ["00"] = true, ["4"] = true, ["62"] = true, ["7"] = true,
    ["78899"] = true, ["83260119948695"] = true, ["9"] = true,
    ["0108810778294510"] = true, ["0199398092507736"] = true, ["0781783795929384"] = true,
    ["0882743793919682"] = true, ["0786733496929883"] = true, ["0989793195949985"] = true,
    ["0183783896919488"] = true, ["0984713992949389"] = true, ["0986773792959688"] = true,
    ["0985713898939984"] = true, ["0786783498929680"] = true, ["0183793190919484"] = true,
    ["0189703096999382"] = true, ["0983753496919385"] = true, ["0183743695959783"] = true,
    ["0983793198959980"] = true, ["0182773596959281"] = true, ["0701860973294016"] = true,
    ["0892368292547530"] = true, ["0786763499909587"] = true, ["0884763096989481"] = true,
    ["0780743091909187"] = true, ["0782743599959081"] = true, ["0183783996929185"] = true,
    ["0983713196969281"] = true, ["0781723896919581"] = true, ["0980743499979185"] = true,
    ["0981733293939487"] = true, ["0988703591949485"] = true, ["0786733893909988"] = true,
    ["0983753391989386"] = true, ["0980763593949783"] = true, ["0780733399959388"] = true,
    ["0987793695939280"] = true, ["0707800870204214"] = true, ["0199308793587830"] = true,
    ["0785703393959680"] = true, ["0185713897949589"] = true, ["0980763695989488"] = true,
    ["0984753093999887"] = true, ["0187743193919582"] = true, ["0188783290929287"] = true,
    ["0985743792939782"] = true, ["0182783190949685"] = true, ["0880783994969984"] = true,
    ["0180713390929485"] = true, ["0781733892959484"] = true, ["0180773895939089"] = true,
    ["0887743792949281"] = true, ["0181733392989187"] = true, ["0982773891929683"] = true,
    ["0101840172294612"] = true, ["0796368397507834"] = true, ["0188783393959182"] = true,
    ["0887763498959481"] = true, ["0984783496939584"] = true, ["0888723595919882"] = true,
    ["0885793399989982"] = true, ["0184753092969383"] = true, ["0184783093909781"] = true,
    ["0783783391939186"] = true, ["0785743793979780"] = true, ["0780743099919086"] = true,
    ["0989733695939088"] = true, ["0184793895939289"] = true, ["0785793399949385"] = true,
    ["0184703996929084"] = true, ["0183713190949782"] = true, ["0808870174284014"] = true,
    ["0193388091597930"] = true, ["0781753494949789"] = true, ["0788743498969686"] = true,
    ["0881753896909982"] = true, ["0983753499969680"] = true, ["0788723394989684"] = true,
    ["0981703093929280"] = true, ["0788793192999781"] = true, ["0984753591979288"] = true,
    ["0880703998949382"] = true, ["0186773596929986"] = true, ["0880763299919380"] = true,
    ["0783773994949784"] = true, ["0980793090969783"] = true, ["0181763099929887"] = true,
    ["0783753898919286"] = true, ["0909870178244918"] = true, ["0799338697567436"] = true,
    ["0984773991979984"] = true, ["0988753090949787"] = true, ["0181723395969783"] = true,
    ["0782773199969487"] = true, ["0985713696959183"] = true, ["0883763294919084"] = true,
    ["0787783891939485"] = true, ["0984733396969989"] = true, ["0888763095949880"] = true,
    ["0785723596929981"] = true, ["0888783890909188"] = true, ["0187783697909488"] = true,
    ["0989713598999384"] = true, ["0184723190979886"] = true, ["0988753090969383"] = true,
    ["0109850178264618"] = true, ["0892358297597230"] = true, ["0884723292989484"] = true,
    ["0980733991999787"] = true, ["0984773695939282"] = true, ["0989723796959389"] = true,
    ["0189783094909381"] = true, ["0186743799949788"] = true, ["0986733193929087"] = true,
    ["0183713995959986"] = true, ["0781753792909189"] = true, ["0788763293949185"] = true,
    ["0180723090989382"] = true, ["0780713698979981"] = true, ["0188743491989881"] = true,
    ["0187763692919288"] = true, ["0182783696929785"] = true, ["0808810977264616"] = true,
    ["0194338691597932"] = true, ["0783733098909083"] = true, ["0789793494909588"] = true,
    ["0780703596989486"] = true, ["0188723298949286"] = true, ["0780753792949083"] = true,
    ["0187753799979983"] = true, ["0984763998989986"] = true, ["0880743197909882"] = true,
    ["0885773396999582"] = true, ["0182773390989789"] = true, ["0887713595959981"] = true,
    ["0889783195989081"] = true, ["0781753095949381"] = true, ["0189733197909187"] = true,
    ["0983783899999883"] = true, ["0192388190537434"] = true, ["0886703896939887"] = true,
    ["0782753599949287"] = true, ["0884723096979986"] = true, ["0980743896969080"] = true,
    ["0784793695989987"] = true, ["0784733694949689"] = true, ["0782713992919281"] = true,
    ["0989753291919381"] = true, ["0789723891949487"] = true, ["0888763691979681"] = true,
    ["0789763191989883"] = true, ["0189783798999486"] = true, ["0182753596939588"] = true,
    ["0885793099959687"] = true, ["0981763499949187"] = true, ["0709890172214113"] = true,
    ["0798358591567232"] = true, ["0783733698969083"] = true, ["0187743895949087"] = true,
    ["0981703391929284"] = true, ["0988783092909084"] = true, ["0785733895949586"] = true,
    ["0181713490989281"] = true, ["0181743597979382"] = true, ["0784753098939083"] = true,
    ["0984723696979089"] = true, ["0885723799909886"] = true, ["0885743598939388"] = true,
    ["0784763696909181"] = true, ["0887713199959383"] = true, ["0985783490969682"] = true,
    ["0887753392959582"] = true, ["0188743591949081"] = true, ["0788773899929181"] = true,
    ["0884733094979480"] = true, ["0882713393929486"] = true, ["0988793191919985"] = true,
    ["0980763091949688"] = true, ["0981763790949989"] = true, ["0784783790989980"] = true,
    ["0189783096949884"] = true, ["0889713695959887"] = true, ["0789743599969886"] = true,
    ["0808840770274218"] = true, ["0894308298547233"] = true, ["0889723198909582"] = true,
    ["0189753198939582"] = true, ["0984753194999688"] = true, ["0789793899989784"] = true,
    ["0185703797999985"] = true, ["0187783492949484"] = true, ["0185763094949182"] = true,
    ["0982723590979182"] = true, ["0888793792909283"] = true, ["0880723399929786"] = true,
    ["0183703297969781"] = true, ["0782733295979288"] = true, ["0987793998979382"] = true,
    ["0881763098939082"] = true, ["0785703193949689"] = true, ["0908850878214113"] = true,
    ["0190328396527935"] = true, ["0985793992939380"] = true, ["0187713898909285"] = true,
    ["0783793990989782"] = true, ["0180723297989088"] = true, ["0986703392999981"] = true,
    ["0888783094989186"] = true, ["0782713595949889"] = true, ["0189763696929584"] = true,
    ["0182783795949188"] = true, ["0985763892959682"] = true, ["0187743298989089"] = true,
    ["0785733094929888"] = true, ["0986753693979888"] = true, ["0985783396959488"] = true,
    ["0780743691979380"] = true, ["0801820179264512"] = true, ["0998308095527431"] = true,
    ["0783723591999680"] = true, ["0883723198999384"] = true, ["0780743495909089"] = true,
    ["0986773597969587"] = true, ["0188733893989481"] = true, ["0783723096929587"] = true,
    ["0980773994929186"] = true, ["0883733490929188"] = true, ["0789703094929781"] = true,
    ["0783733794979082"] = true, ["0889743993989784"] = true, ["0181743099969582"] = true,
    ["0789793597969384"] = true, ["0886763394919281"] = true, ["0789733192919885"] = true,
    ["0701800777204513"] = true, ["0191348098537733"] = true, ["0880723198909183"] = true,
    ["0783703795919786"] = true, ["0184733591949081"] = true, ["0983703491999880"] = true,
    ["0980763092909188"] = true, ["0784713895949081"] = true, ["0189743394969288"] = true,
    ["0183763291959382"] = true, ["0185733598989881"] = true, ["0885763097999685"] = true,
    ["0187783798999185"] = true, ["0782713591969586"] = true, ["0787763799969881"] = true,
    ["0988713091959286"] = true, ["0192358793587532"] = true, ["0885773993999584"] = true,
    ["0888753192969383"] = true, ["0982703891939186"] = true, ["0783723399959889"] = true,
    ["0788703292959386"] = true, ["0186713595919881"] = true, ["0981763391939381"] = true,
    ["0980793192979186"] = true, ["0780783698989989"] = true, ["0888773491969581"] = true,
    ["0883753099939887"] = true, ["0787773891909986"] = true, ["0888703093949889"] = true,
    ["0886703692969387"] = true, ["0980773094939681"] = true, ["0901800970264215"] = true,
    ["0891358599507632"] = true, ["0188703195909281"] = true, ["0783743799989385"] = true,
    ["0983783095959880"] = true, ["0886733497979788"] = true, ["0184763499939188"] = true,
    ["0781783392949584"] = true, ["0881723796929682"] = true, ["0101820173254317"] = true,
    ["0895308090547039"] = true, ["0885793896969985"] = true, ["0182733091929984"] = true,
    ["0888723093969981"] = true, ["0183783794909883"] = true, ["0785783899999380"] = true,
    ["0187753396919883"] = true, ["0785753293909180"] = true, ["0886743094909689"] = true,
    ["0184763392979788"] = true, ["0882723098949988"] = true, ["0888743391949381"] = true,
    ["0987763294939987"] = true, ["0182773295909083"] = true, ["0787713398999181"] = true,
    ["0185763696969587"] = true, ["0109840770244215"] = true, ["0992338090507430"] = true,
    ["0188733897949588"] = true, ["0183783192999384"] = true, ["0183743792929887"] = true,
    ["0984763495929686"] = true, ["0887783798999581"] = true, ["0982713190999789"] = true,
    ["0888753395969688"] = true, ["0784723399919889"] = true, ["0886703992989780"] = true,
    ["0185713991909787"] = true, ["0782723495929881"] = true, ["0984763698919582"] = true,
    ["0184723194919981"] = true, ["0788763996939284"] = true, ["0180703695919483"] = true,
    ["0801830779204219"] = true, ["0896308299557735"] = true, ["0787713998929382"] = true,
    ["0784783796999889"] = true, ["0989753995939080"] = true, ["0180723195959383"] = true,
    ["0187743097969186"] = true, ["0785773690929780"] = true, ["0187753392999287"] = true,
    ["0887793790999488"] = true, ["0188723090979780"] = true, ["0184773595979585"] = true,
    ["0782733697969089"] = true, ["0780783597919383"] = true, ["0186743690979981"] = true,
    ["0185733594969481"] = true, ["0882743994919182"] = true, ["0801800172204511"] = true,
    ["0191368593557936"] = true, ["0786763290979880"] = true, ["0780763392979581"] = true,
    ["0189723499979283"] = true, ["0981703497969481"] = true, ["0187783896999588"] = true,
    ["0787723398989685"] = true, ["0981713390919087"] = true, ["0887753993959881"] = true,
    ["0883793891989586"] = true, ["0984753392939785"] = true, ["0886733098969384"] = true,
    ["0782753390999882"] = true, ["0189783496949581"] = true, ["0883763090969681"] = true,
    ["0985773994909288"] = true, ["0994388590567332"] = true, ["0184723698979486"] = true,
    ["0884723690979081"] = true, ["0186733390969885"] = true, ["0882723592959284"] = true,
    ["0188773593919185"] = true, ["0980773097909282"] = true, ["0981783996919488"] = true,
    ["0180743999959085"] = true, ["0881783596919184"] = true, ["0784743493939187"] = true,
    ["0980793294969787"] = true, ["0880713892909982"] = true, ["0786703990939086"] = true,
    ["0186763797919889"] = true, ["0888753395949286"] = true, ["0109840871214017"] = true,
    ["0990308899577433"] = true, ["0783733195939085"] = true, ["0884703095979184"] = true,
    ["0784723997959985"] = true, ["0187703791979383"] = true, ["0788773796989682"] = true,
    ["0881703898919987"] = true, ["0987723692929883"] = true, ["0885763499949286"] = true,
    ["0784793098969785"] = true, ["0187773494989880"] = true, ["0987723798919685"] = true,
    ["0187783590999284"] = true, ["0985723092969389"] = true, ["0185773397919389"] = true,
    ["0982733892919983"] = true, ["0984703499989684"] = true, ["0181753292939787"] = true,
    ["0882703594969587"] = true, ["0984773996969180"] = true, ["0785763699929483"] = true,
    ["0785793599959384"] = true, ["0784723795949687"] = true, ["0186723799909284"] = true,
    ["0783793690999889"] = true, ["0982733290939981"] = true, ["0987743097989384"] = true,
    ["0801810177204011"] = true, ["0795358991527338"] = true, ["0882713891909786"] = true,
    ["0782733499999588"] = true, ["0780753199929885"] = true, ["0982763891979187"] = true,
    ["0184793798909987"] = true, ["0984713093969986"] = true, ["0788733595969988"] = true,
    ["0885703192989183"] = true, ["0184753498909480"] = true, ["0886733997959482"] = true,
    ["0987773495949587"] = true, ["0980763993919680"] = true, ["0886783491929881"] = true,
    ["0889773790989484"] = true, ["0182723394939788"] = true, ["0808880976224912"] = true,
    ["0195358793527038"] = true, ["0783733194949881"] = true, ["0787793891919787"] = true,
    ["0182753593959183"] = true, ["0886773599959389"] = true, ["0783793593989480"] = true,
    ["0783743692989683"] = true, ["0186703293969985"] = true, ["0187793998909182"] = true,
    ["0786763992969088"] = true, ["0184723992989381"] = true, ["0187773294979088"] = true,
    ["92959928042658"] = true, ["011385279262018"] = true, ["09994515630714"] = true,
    ["011326598673692"] = true, ["077550134709741"] = true, ["07951842076613"] = true,
    ["071560938644685"] = true, ["07821477360742"] = true, ["081345779523465"] = true,
    ["017688091565127"] = true, ["07918723561950"] = true, ["018211452065459"] = true,
    ["07183087914907"] = true, ["019315235107157"] = true, ["0871859258340"] = true,
    ["091269972715084"] = true, ["0799551467329"] = true, ["091973916888375"] = true,
    ["0982617992336"] = true, ["011639551361098"] = true, ["0853714926386"] = true,
    ["071497817217804"] = true, ["0983182171081"] = true, ["079946628353097"] = true,
    ["0124809374688"] = true, ["097183071561137"] = true, ["08998326561150"] = true,
    ["018417422066489"] = true, ["01153381964208"] = true, ["079118285507177"] = true,
    ["0978889252320"] = true, ["011269932217084"] = true, ["0190501565359"] = true,
    ["071974976783385"] = true, ["0184697292396"] = true, ["071633521367098"] = true,
    ["0852714822326"] = true, ["091196887613854"] = true, ["0783182373011"] = true,
    ["079247628551017"] = true, ["0726819870688"] = true, ["097989011661187"] = true,
    ["09948822521653"] = true, ["018311462164489"] = true, ["09103980984409"] = true,
    ["099017215709157"] = true, ["0771869755380"] = true, ["011066912017014"] = true,
    ["0194591064369"] = true, ["081672956687315"] = true, ["0983627494306"] = true,
    ["071833581360088"] = true, ["0855764325356"] = true, ["091391837919824"] = true,
    ["0786132671081"] = true, ["089247698450077"] = true, ["0123849779658"] = true,
    ["071688544429835"] = true, ["09659378185308"] = true, ["08841972560143"] = true,
    ["091299851167372"] = true, ["07571586945479"] = true, ["081984231041968"] = true,
    ["0914726025104958"] = true, ["0887495622844"] = true, ["091924845169964"] = true,
    ["0852631074562"] = true, ["081893774027081"] = true, ["0895108621015"] = true,
    ["012175998815087"] = true, ["0186254154876"] = true, ["011353094621125"] = true,
    ["0998471756948"] = true, ["081898744526011"] = true, ["0895158825075"] = true,
    ["011890754227081"] = true, ["0795198022015"] = true, ["011898704322071"] = true,
    ["0895148021015"] = true, ["011897704827011"] = true, ["0795198921095"] = true,
    ["071890744220011"] = true, ["0195148728085"] = true, ["011895764924071"] = true,
    ["071086299165088"] = true, ["07924111650117"] = true, ["011527538676692"] = true,
    ["077456144907771"] = true, ["09951445096416"] = true, ["011365928149695"] = true,
    ["09861171370147"] = true, ["081943719720445"] = true, ["077385071762157"] = true,
    ["09908829571253"] = true, ["098411492360489"] = true, ["01123187944409"] = true,
    ["019315205409197"] = true, ["0778869759320"] = true, ["011364972314014"] = true,
    ["0195561762379"] = true, ["081071986380365"] = true, ["0188657094326"] = true,
    ["081038521867078"] = true, ["0955724727326"] = true, ["091394897311884"] = true,
    ["0180192675081"] = true, ["089341618356017"] = true, ["0127859276678"] = true,
    ["077587091164187"] = true, ["09938526521958"] = true, ["018911402966409"] = true,
    ["07173881954507"] = true, ["019214225201197"] = true, ["0779889753300"] = true,
    ["091560962317014"] = true, ["0192501668349"] = true, ["081876906984345"] = true,
    ["0184607390376"] = true, ["081337541960088"] = true, ["0152784929356"] = true,
    ["091490857817864"] = true, ["0184122373091"] = true, ["099943698455087"] = true,
    ["0821859379668"] = true, ["077283091163127"] = true, ["09928221571258"] = true,
    ["078518452168469"] = true, ["07103286954201"] = true, ["079610285501147"] = true,
    ["0974829551340"] = true, ["091063922810084"] = true, ["0191561764349"] = true,
    ["011175986989325"] = true, ["0780677690336"] = true, ["091232501467098"] = true,
    ["0752774620366"] = true, ["081790867614854"] = true, ["0988112876081"] = true,
    ["089545668554017"] = true, ["0123849777638"] = true, ["091883534522845"] = true,
    ["01659378195308"] = true, ["07841575570846"] = true, ["081294871260352"] = true,
    ["09571786915577"] = true, ["081989221641908"] = true, ["0914706725114158"] = true,
    ["0987435326814"] = true, ["091920835967924"] = true, ["0752621174572"] = true,
    ["0822889773688"] = true, ["071587514624875"] = true, ["09659778105707"] = true,
    ["09841071520943"] = true, ["071298801063362"] = true, ["09571882955878"] = true,
    ["071984221041998"] = true, ["0814796828124954"] = true, ["0987415124834"] = true,
    ["071920835362914"] = true, ["0852661178522"] = true, ["091890764020071"] = true,
    ["0795138028095"] = true, ["012176958317097"] = true, ["0986234852816"] = true,
    ["091353074023145"] = true, ["0798481652928"] = true, ["091890724326011"] = true,
    ["0195108526075"] = true, ["071896754924011"] = true, ["0795168425075"] = true,
    ["091892714528011"] = true, ["0195138923085"] = true, ["081891784128091"] = true,
    ["0195188129085"] = true, ["071895754825071"] = true, ["0895188623015"] = true,
    ["0121899179628"] = true, ["091281544222875"] = true, ["07659675145608"] = true,
    ["07841274530748"] = true, ["081298881760382"] = true, ["01571587995974"] = true,
    ["091984251842958"] = true, ["0914766328194558"] = true, ["0187465228804"] = true,
    ["071927835364984"] = true, ["0752651476552"] = true, ["091894714929081"] = true,
    ["0995158222015"] = true, ["082176928012077"] = true, ["0886204854836"] = true,
    ["011353014927155"] = true, ["0198431758978"] = true, ["081896744222081"] = true,
    ["0795198323095"] = true, ["071899724728071"] = true, ["0995188622015"] = true,
    ["011891784427081"] = true, ["0995108724015"] = true, ["081893754923011"] = true,
    ["0195188522085"] = true, ["011893714320091"] = true, ["0895108027085"] = true,
    ["0123899571668"] = true, ["081380534324885"] = true, ["08659778175007"] = true,
    ["01841477540740"] = true, ["011299801767352"] = true, ["09571982975175"] = true,
    ["091988271246978"] = true, ["0714726621104450"] = true, ["0887415027834"] = true,
    ["071924815567954"] = true, ["0852601379502"] = true, ["091896774324081"] = true,
    ["0195108722095"] = true, ["092175908312087"] = true, ["0986224056806"] = true,
    ["011354014023115"] = true, ["0898451158918"] = true, ["071894714228011"] = true,
    ["0795148721015"] = true, ["091897734829091"] = true, ["0795148023085"] = true,
    ["081899704925091"] = true, ["0995128622085"] = true, ["071894744429091"] = true,
    ["0895138323085"] = true, ["091894764227081"] = true, ["0895148529095"] = true,
    ["0721899072648"] = true, ["011483514122895"] = true, ["01659671185207"] = true,
    ["07841178580742"] = true, ["091294891269352"] = true, ["09571684955678"] = true,
    ["071980291747978"] = true, ["0714786529134058"] = true, ["0787475825834"] = true,
    ["071921895764914"] = true, ["0152601678542"] = true, ["011897754825071"] = true,
    ["0195158823075"] = true, ["092179938119017"] = true, ["0786244855816"] = true,
    ["011356074928185"] = true, ["0898461950938"] = true, ["011897784425091"] = true,
    ["0895148821075"] = true, ["091896704025091"] = true, ["0895148924015"] = true,
    ["011893784325081"] = true, ["0795178024095"] = true, ["071897744426081"] = true,
    ["0195108125015"] = true, ["091899794921081"] = true, ["0795158724075"] = true,
    ["0926839372678"] = true, ["081188514322835"] = true, ["01659076185509"] = true,
    ["08841978570844"] = true, ["091294871067312"] = true, ["01571980955972"] = true,
    ["081989201347938"] = true, ["0714766924184050"] = true, ["0987485721854"] = true,
    ["091921825468994"] = true, ["0852601871512"] = true, ["091898714225091"] = true,
    ["0195108425095"] = true, ["072173958310077"] = true, ["0786244957816"] = true,
    ["071357094027175"] = true, ["0998421159988"] = true, ["091895724521081"] = true,
    ["0995138421015"] = true, ["071899704629081"] = true, ["0795178227015"] = true,
    ["081894774829081"] = true, ["0895168829015"] = true, ["011898744921071"] = true,
    ["0895148521095"] = true, ["071892764027071"] = true, ["0995168325075"] = true,
    ["011898704226071"] = true, ["0195138926085"] = true, ["092171988218017"] = true,
    ["0786204956866"] = true, ["081352084524175"] = true, ["0898441859978"] = true,
    ["071891744821081"] = true, ["0195178522015"] = true, ["071893704220091"] = true,
    ["0195118529075"] = true, ["071896754028081"] = true, ["0195108623075"] = true,
    ["011897734424011"] = true, ["0995138428075"] = true, ["091890724729091"] = true,
    ["0195118922085"] = true, ["091890734626081"] = true, ["0795118722075"] = true,
    ["081896744726071"] = true, ["0195138627095"] = true, ["071897764025071"] = true,
    ["0895148921095"] = true, ["011348769822455"] = true, ["091341789824485"] = true,
    ["011446729625465"] = true, ["011347729328475"] = true, ["091347779828455"] = true,
    ["011646719221415"] = true, ["0195168928015"] = true, ["012179978912097"] = true,
    ["0986234058846"] = true, ["091356094928115"] = true, ["0198471254958"] = true,
    ["091893714427091"] = true, ["0895148222075"] = true, ["071891764621081"] = true,
    ["0795118420015"] = true, ["081897794826081"] = true, ["0795168823015"] = true,
    ["071892774220011"] = true, ["0895128029095"] = true, ["011896704123091"] = true,
    ["0995158328015"] = true, ["081892714228091"] = true, ["0895198520085"] = true,
    ["011897734725011"] = true, ["0795158020015"] = true, ["071890734028071"] = true,
    ["0795188526095"] = true, ["091895764223081"] = true, ["0195158328015"] = true,
    ["091892794920081"] = true, ["0995118123085"] = true, ["081894784927011"] = true,
    ["0895128221015"] = true, ["081893744625081"] = true, ["0995108026075"] = true,
    ["071345779620455"] = true, ["011544719528405"] = true, ["071347729124465"] = true,
    ["091444799724455"] = true, ["081249719020455"] = true, ["071745709320435"] = true,
    ["0195198429015"] = true, ["092177918713017"] = true, ["0186284553856"] = true,
    ["091355014420125"] = true, ["0898431254978"] = true,
    ["0106800577264015"] = true, ["0090308297517537"] = true, ["0082763296909182"] = true,
    ["0097092766723028"] = true, ["001487259163048"] = true, ["00984317620519"] = true,
    ["001320598471652"] = true, ["007659184302781"] = true, ["00971542086317"] = true,
    ["001563908247615"] = true, ["00821475390648"] = true, ["001145739628405"] = true,
    ["007482051963147"] = true, ["00938627541052"] = true, ["008719452861439"] = true,
    ["00153682974105"] = true, ["009417285603187"] = true, ["0072849156380"] = true,
    ["001865942713084"] = true, ["0092541768309"] = true, ["001174926580315"] = true,
    ["0084617295306"] = true, ["001938571462098"] = true, ["0056714928306"] = true,
    ["001692847513894"] = true, ["0085142976031"] = true, ["009741638259047"] = true,
    ["0024819573608"] = true, ["001780564921835"] = true, ["00659274185609"] = true,
    ["00841679520841"] = true, ["001295841760392"] = true, ["00571486925071"] = true,
    ["001985271640958"] = true, ["0014796528174059"] = true, ["0087415926804"] = true,
    ["001927845160984"] = true, ["0052641879502"] = true, ["001895714628051"] = true,
    ["0095168427095"] = true, ["002174958613047"] = true, ["0086294751806"] = true,
    ["001358074926185"] = true, ["0098461752908"] = true, ["0059274185609"] = true,
    ["0041679520841"] = true, ["00195841760392"] = true, ["0051486925071"] = true,
    ["00185271640958"] = true, ["005796528174059"] = true, ["005415926804"] = true,
    ["00527845160984"] = true, ["005641879502"] = true, ["005168427095"] = true,
    ["00358074926185"] = true, ["008461752908"] = true, ["115897193508594"] = true,
    ["00120104871360327"] = true, ["00129060362076134"] = true,
    ["101631982347841"] = true, ["112210298860778"] = true,
    ["115819698454027"] = true, ["116331922770563"] = true,
    ["117391349741339"] = true, ["117871196330268"] = true,
    ["120313493879944"] = true, ["134216333534795"] = true,
    ["137555839480738"] = true, ["140497415402103"] = true,
    ["54410081542"] = true, ["70999314371231"] = true,
    ["71352236"] = true, ["76500780055460"] = true,
    ["78515442941510"] = true, ["90533928572341"] = true,
    ["99721399503975"] = true, ["00101020203030404"] = true,
    ["00112233445566778"] = true, ["00123456789012345"] = true,
    ["00135791357913579"] = true, ["00159260374815926"] = true,
    ["00246802468024680"] = true, ["00405060708090001"] = true,
    ["00543210987654321"] = true, ["00731959731959731"] = true,
    ["00864208642086420"] = true, ["00887766554433221"] = true,
    ["00975319753197531"] = true, ["00987654321098765"] = true,
    ["00998877665544332"] = true, ["129569049476734"] = true,
    ["81067084464165"] = true, ["00159837264918375"] = true,
    ["123728962822472"] = true
}

-- ==================== Helper Functions ====================
local function urlDecode(str)
    if not str then return "" end
    str = string.gsub(str, "+", " ")
    return (string.gsub(str, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

local function hexDecode(str)
    if not str then return "" end
    str = string.gsub(str, "0x", "")
    str = string.gsub(str, "\\x", "")
    str = string.gsub(str, "%%", "")
    str = string.gsub(str, "%s+", "")
    if string.match(str, "^%x+$") and #str % 2 == 0 then
        local decoded = ""
        for i = 1, #str, 2 do
            local byteStr = string.sub(str, i, i+1)
            local byte = tonumber(byteStr, 16)
            if byte then decoded = decoded .. string.char(byte) end
        end
        if #decoded > 0 then return decoded end
    end
    return str
end

local function deepDecode(str)
    if type(str) ~= "string" then return str end
    local prev
    repeat
        prev = str
        str = urlDecode(str)
        str = hexDecode(str)
    until str == prev
    return str
end

local function extractIDsFromPattern(text)
    local ids = {}
    local patterns = {
        "69%%64=([^&]*)", "&id=([^&]*)", "id=([^&]*)",
        "audio=([^&]*)", "song=([^&]*)", "music=([^&]*)",
        "%%69%%64=([^&]*)", "&%%69%%64=([^&]*)"
    }
    for _, pat in ipairs(patterns) do
        for capture in string.gmatch(text, pat) do
            for num in string.gmatch(capture, "%d+") do
                if not BlockedIDs[num] then table.insert(ids, num) end
            end
        end
    end
    return ids
end

local function getPlayerVehicle(player)
    if not player or not player.Character then return nil end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then return nil end
    local vehicle = humanoid.SeatPart.Parent
    while vehicle and not vehicle:IsA("Model") do vehicle = vehicle.Parent end
    return (vehicle and vehicle:IsA("Model")) and vehicle or nil
end

local NameBlacklist = {
    ["gettingup"] = true, ["died"] = true, ["freefalling"] = true,
    ["jumping"] = true, ["landing"] = true, ["running"] = true,
    ["splash"] = true, ["swimming"] = true, ["climbing"] = true,
    ["skateboard"] = true, ["skate"] = true, ["board"] = true,
    ["car"] = true, ["vehicle"] = true, ["bike"] = true,
    ["scooter"] = true, ["bicycle"] = true, ["motorcycle"] = true,
    ["engine"] = true, ["motor"] = true, ["horn"] = true,
    ["tire"] = true, ["wheel"] = true, ["brake"] = true,
    ["squeak"] = true, ["driving"] = true, ["road"] = true,
    ["crash"] = true, ["impact"] = true, ["bump"] = true
}

local function checkPlayerAllSounds(targetPlayer)
    if not targetPlayer then return {} end
    local scanTargets = {}
    if targetPlayer.Character then table.insert(scanTargets, targetPlayer.Character) end
    local backpack = targetPlayer:FindFirstChild("Backpack")
    if backpack then table.insert(scanTargets, backpack) end
    local vehicle = getPlayerVehicle(targetPlayer)
    if vehicle then table.insert(scanTargets, vehicle) end

    local validSounds = {}
    local soundMap = {}
    for _, folder in ipairs(scanTargets) do
        local success, descendants = pcall(function() return folder:GetDescendants() end)
        if success and descendants then
            for _, obj in ipairs(descendants) do
                if obj:IsA("Sound") and obj.SoundId ~= "" and obj.IsPlaying then
                    local soundNameLower = string.lower(obj.Name)
                    local isBlacklisted = false
                    for blockedName, _ in pairs(NameBlacklist) do
                        if string.find(soundNameLower, blockedName) then
                            isBlacklisted = true
                            break
                        end
                    end
                    if not isBlacklisted then
                        local key = obj.SoundId
                        if not soundMap[key] then
                            soundMap[key] = true
                            table.insert(validSounds, obj)
                        end
                    end
                end
            end
        end
    end
    return validSounds
end

local function copyToClipboard(text)
    local setclip = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if setclip then setclip(text) end
end

-- ⭐ playMusicFromId: ยิงทั้ง Boombox และ สกู๊ตเตอร์/สเก็ต (แบบไม่บัค)
local function playMusicFromId(musicId)
    if not musicId or musicId == "" then return false end
    local re = ReplicatedStorage:FindFirstChild("RE")
    
    if re then
        local success1, success2 = false, false
        
        -- 1. ยิงรีโมทสำหรับลำโพง (Boombox)
        local event1 = re:FindFirstChild("PlayerToolEvent")
        if event1 then
            local args1 = { "ToolMusicText", musicId, "", [4] = true }
            success1 = pcall(function() event1:FireServer(unpack(args1)) end)
        end
        
        -- 2. รอเสี้ยววินาที เพื่อให้เซิร์ฟเวอร์ประมวลผลตัวแรกเสร็จก่อน (ป้องกันบัค)
        task.wait(0.1) 
        
        -- 3. ยิงรีโมทสำหรับสกู๊ตเตอร์/สเก็ต (Scooter)
        local event2 = re:FindFirstChild("1NoMoto1rVehicle1s")
        if event2 then
            -- ใช้ "PickingScooterMusicText" และส่งค่า nil ไปที่ช่อง 3 ตามที่คุณให้มา
            local args2 = { "PickingScooterMusicText", musicId, nil, [4] = true }
            success2 = pcall(function() event2:FireServer(unpack(args2)) end)
        end
        
        return success1 or success2
    end
    return false
end

local function getAssetInfo(assetId)
    local cleanId = tonumber(string.match(tostring(assetId), "%d+"))
    if not cleanId then return { Title = "ไม่ระบุ", Creator = "ไม่ทราบชื่อ" } end
    if AssetCache[cleanId] then return AssetCache[cleanId] end
    local info = { Title = "กำลังโหลด...", Creator = "กำลังโหลด..." }
    task.spawn(function()
        local success, result = pcall(function()
            return MarketplaceService:GetProductInfo(cleanId, Enum.InfoType.Asset)
        end)
        if success and result then
            info.Title = result.Name or "ไม่มีชื่อ"
            info.Creator = (result.Creator and result.Creator.Name) or "ไม่ระบุ"
            AssetCache[cleanId] = info
        else
            info.Title = "ไม่สามารถดึงข้อมูลได้ (ส่วนตัว/ลบแล้ว)"
            info.Creator = "ไม่ระบุ"
        end
    end)
    return info
end

-- ==================== UI ====================
if PlayerGui:FindFirstChild("WIN84_DeepSoundSpy") then PlayerGui.WIN84_DeepSoundSpy:Destroy() end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "WIN84_DeepSoundSpy"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function setDrag(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 240)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.ZIndex = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local mStroke = Instance.new("UIStroke", MainFrame)
mStroke.Color = Color3.fromRGB(60, 60, 60)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.ZIndex = 2
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
setDrag(MainFrame, TopBar)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DEEP VALIDATOR SCANNER - ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

local ListScroll = Instance.new("ScrollingFrame", MainFrame)
ListScroll.Size = UDim2.new(0.45, 0, 0, 155)
ListScroll.Position = UDim2.new(0.03, 0, 0.18, 0)
ListScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 4
ListScroll.ZIndex = 2
Instance.new("UICorner", ListScroll).CornerRadius = UDim.new(0, 5)

local Layout = Instance.new("UIListLayout", ListScroll)
Layout.Padding = UDim.new(0, 4)

local ButtonsContainer = Instance.new("Frame", MainFrame)
ButtonsContainer.Size = UDim2.new(0.47, 0, 0, 155)
ButtonsContainer.Position = UDim2.new(0.5, 0, 0.18, 0)
ButtonsContainer.BackgroundTransparency = 1
ButtonsContainer.ZIndex = 2

local BLayout = Instance.new("UIListLayout", ButtonsContainer)
BLayout.Padding = UDim.new(0, 3)

local function createMenuButton(text, color)
    local btn = Instance.new("TextButton", ButtonsContainer)
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

local GetIDBtn = createMenuButton("⚡ เจาะและดึงไอดีทั้งหมดทันที", Color3.fromRGB(255, 215, 0))
GetIDBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
local GetJunkBtn = createMenuButton("🎵 เปิดเพลงตาม + บันทึก", Color3.fromRGB(230, 90, 40))
local ViewRawJunkBtn = createMenuButton("👁️ ดูข้อความ RAW ดิบของผู้เล่น", Color3.fromRGB(140, 20, 230))
local ViewInstantBtn = createMenuButton("🔍 ดู ID เจาะทั้งหมด (Real-time)", Color3.fromRGB(0, 200, 100))
local MyAudioBtn = createMenuButton("🎧 ดูข้อมูลเพลงบนตัวเรา (Real-time)", Color3.fromRGB(230, 0, 120))
local SavedSongsBtn = createMenuButton("⭐ เพลงที่บันทึกไว้ (Saved)", Color3.fromRGB(0, 150, 255))

StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.68, 0, 0, 24)
StatusLabel.Position = UDim2.new(0.03, 0, 0.86, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
StatusLabel.BackgroundTransparency = 0.9
StatusLabel.Text = "โหลดรายการเพลงเก่าเรียบร้อย!"
StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextWrapped = true
StatusLabel.ZIndex = 2
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 4)

local RefreshBtn = Instance.new("TextButton", MainFrame)
RefreshBtn.Size = UDim2.new(0.24, 0, 0, 24)
RefreshBtn.Position = UDim2.new(0.73, 0, 0.86, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RefreshBtn.Text = "🔄 รีเฟรชรายชื่อ"
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 10
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.ZIndex = 2
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 46, 0, 46)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleBtn.Text = "🎵"
ToggleBtn.TextSize = 18
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.ZIndex = 100
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 23)
setDrag(ToggleBtn, ToggleBtn)

local JunkFrame = Instance.new("Frame", ScreenGui)
JunkFrame.Size = UDim2.new(0, 420, 0, 240)
JunkFrame.Position = UDim2.new(0.5, -210, 0.5, -120)
JunkFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
JunkFrame.Visible = false
JunkFrame.ZIndex = 10
Instance.new("UICorner", JunkFrame).CornerRadius = UDim.new(0, 8)
local jStroke = Instance.new("UIStroke", JunkFrame)
jStroke.Color = Color3.fromRGB(140, 20, 230)
jStroke.Thickness = 1.5

local JunkTopBar = Instance.new("Frame", JunkFrame)
JunkTopBar.Size = UDim2.new(1, 0, 0, 32)
JunkTopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
JunkTopBar.ZIndex = 11
Instance.new("UICorner", JunkTopBar).CornerRadius = UDim.new(0, 8)
setDrag(JunkFrame, JunkTopBar)

local JunkTitle = Instance.new("TextLabel", JunkTopBar)
JunkTitle.Size = UDim2.new(1, -10, 1, 0)
JunkTitle.Position = UDim2.new(0, 12, 0, 0)
JunkTitle.BackgroundTransparency = 1
JunkTitle.Text = "VIEWER WINDOW"
JunkTitle.TextColor3 = Color3.fromRGB(200, 100, 255)
JunkTitle.Font = Enum.Font.GothamBold
JunkTitle.TextSize = 11
JunkTitle.TextXAlignment = Enum.TextXAlignment.Left
JunkTitle.ZIndex = 12

local JunkScroll = Instance.new("ScrollingFrame", JunkFrame)
JunkScroll.Size = UDim2.new(0.94, 0, 0, 150)
JunkScroll.Position = UDim2.new(0.03, 0, 0.18, 0)
JunkScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
JunkScroll.BorderSizePixel = 0
JunkScroll.ScrollBarThickness = 4
JunkScroll.ZIndex = 11
Instance.new("UICorner", JunkScroll).CornerRadius = UDim.new(0, 5)

local SavedContainer = Instance.new("Frame", JunkScroll)
SavedContainer.Size = UDim2.new(1, 0, 1, 0)
SavedContainer.BackgroundTransparency = 1
SavedContainer.Visible = false
SavedContainer.ZIndex = 12
local SavedLayout = Instance.new("UIListLayout", SavedContainer)
SavedLayout.Padding = UDim.new(0, 4)

local JunkTextLabel = Instance.new("TextLabel", JunkScroll)
JunkTextLabel.Size = UDim2.new(1, -10, 0, 0)
JunkTextLabel.Position = UDim2.new(0, 5, 0, 5)
JunkTextLabel.BackgroundTransparency = 1
JunkTextLabel.Text = "ไม่มีข้อมูล..."
JunkTextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
JunkTextLabel.Font = Enum.Font.Code
JunkTextLabel.TextSize = 11
JunkTextLabel.TextXAlignment = Enum.TextXAlignment.Left
JunkTextLabel.TextYAlignment = Enum.TextYAlignment.Top
JunkTextLabel.TextWrapped = true
JunkTextLabel.ZIndex = 12

local JunkCopyBtn = Instance.new("TextButton", JunkFrame)
JunkCopyBtn.Size = UDim2.new(0.45, 0, 0, 26)
JunkCopyBtn.Position = UDim2.new(0.03, 0, 0.86, 0)
JunkCopyBtn.BackgroundColor3 = Color3.fromRGB(140, 20, 230)
JunkCopyBtn.Text = "📋 คัดลอกทั้งหมด"
JunkCopyBtn.Font = Enum.Font.GothamBold
JunkCopyBtn.TextSize = 11
JunkCopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JunkCopyBtn.ZIndex = 11
Instance.new("UICorner", JunkCopyBtn).CornerRadius = UDim.new(0, 5)

local JunkBackBtn = Instance.new("TextButton", JunkFrame)
JunkBackBtn.Size = UDim2.new(0.45, 0, 0, 26)
JunkBackBtn.Position = UDim2.new(0.52, 0, 0.86, 0)
JunkBackBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JunkBackBtn.Text = "⬅ ย้อนกลับ"
JunkBackBtn.Font = Enum.Font.GothamBold
JunkBackBtn.TextSize = 11
JunkBackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JunkBackBtn.ZIndex = 11
Instance.new("UICorner", JunkBackBtn).CornerRadius = UDim.new(0, 5)

local RenameModal = Instance.new("Frame", ScreenGui)
RenameModal.Size = UDim2.new(0, 300, 0, 140)
RenameModal.Position = UDim2.new(0.5, -150, 0.5, -70)
RenameModal.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RenameModal.Visible = false
RenameModal.ZIndex = 50
Instance.new("UICorner", RenameModal).CornerRadius = UDim.new(0, 8)
local rmStroke = Instance.new("UIStroke", RenameModal)
rmStroke.Color = Color3.fromRGB(0, 150, 255)
rmStroke.Thickness = 2

local rmTitle = Instance.new("TextLabel", RenameModal)
rmTitle.Size = UDim2.new(1, 0, 0, 30)
rmTitle.BackgroundTransparency = 1
rmTitle.Text = "✏️ แก้ไขชื่อเพลง"
rmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
rmTitle.Font = Enum.Font.GothamBold
rmTitle.TextSize = 12
rmTitle.ZIndex = 51

local rmInput = Instance.new("TextBox", RenameModal)
rmInput.Size = UDim2.new(0.88, 0, 0, 32)
rmInput.Position = UDim2.new(0.06, 0, 0.3, 0)
rmInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
rmInput.TextColor3 = Color3.fromRGB(255, 255, 255)
rmInput.Text = ""
rmInput.PlaceholderText = "พิมพ์ชื่อเพลงใหม่ที่นี่..."
rmInput.Font = Enum.Font.Gotham
rmInput.TextSize = 11
rmInput.ClearTextOnFocus = false
rmInput.ZIndex = 51
Instance.new("UICorner", rmInput).CornerRadius = UDim.new(0, 4)

local rmSaveBtn = Instance.new("TextButton", RenameModal)
rmSaveBtn.Size = UDim2.new(0.42, 0, 0, 28)
rmSaveBtn.Position = UDim2.new(0.06, 0, 0.68, 0)
rmSaveBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
rmSaveBtn.Text = "💾 บันทึก"
rmSaveBtn.Font = Enum.Font.GothamBold
rmSaveBtn.TextSize = 11
rmSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rmSaveBtn.ZIndex = 51
Instance.new("UICorner", rmSaveBtn).CornerRadius = UDim.new(0, 4)

local rmCancelBtn = Instance.new("TextButton", RenameModal)
rmCancelBtn.Size = UDim2.new(0.42, 0, 0, 28)
rmCancelBtn.Position = UDim2.new(0.52, 0, 0.68, 0)
rmCancelBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
rmCancelBtn.Text = "❌ ยกเลิก"
rmCancelBtn.Font = Enum.Font.GothamBold
rmCancelBtn.TextSize = 11
rmCancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rmCancelBtn.ZIndex = 51
Instance.new("UICorner", rmCancelBtn).CornerRadius = UDim.new(0, 4)

local TargetRenameSongId = nil

local function openRenameModal(songId, oldName)
    TargetRenameSongId = songId
    rmInput.Text = oldName or ""
    RenameModal.Visible = true
end

local updateSavedSongsUI

rmSaveBtn.MouseButton1Click:Connect(function()
    if TargetRenameSongId and rmInput.Text ~= "" then
        updateSongName(TargetRenameSongId, rmInput.Text)
        StatusLabel.Text = "✅ เปลี่ยนชื่อสำเร็จ: " .. rmInput.Text
        RenameModal.Visible = false
        if updateSavedSongsUI then updateSavedSongsUI() end
    end
end)

rmCancelBtn.MouseButton1Click:Connect(function()
    RenameModal.Visible = false
end)

local CurrentViewMode = 1
local PlayerButtons = {}

updateSavedSongsUI = function()
    for _, child in ipairs(SavedContainer:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    if #SavedSongs == 0 then
        local emptyLabel = Instance.new("TextLabel", SavedContainer)
        emptyLabel.Size = UDim2.new(1, -10, 0, 40)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "❌ ยังไม่มีรายการเพลงที่บันทึกไว้"
        emptyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 11
        emptyLabel.ZIndex = 13
        JunkScroll.CanvasSize = UDim2.new(0, 0, 0, 50)
        return
    end
    local totalHeight = 0
    for idx, songData in ipairs(SavedSongs) do
        local itemFrame = Instance.new("Frame", SavedContainer)
        itemFrame.Size = UDim2.new(1, -10, 0, 32)
        itemFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        itemFrame.ZIndex = 13
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 4)

        local nameLabel = Instance.new("TextLabel", itemFrame)
        nameLabel.Size = UDim2.new(0.48, -5, 1, 0)
        nameLabel.Position = UDim2.new(0, 8, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = string.format("[%d] %s", idx, songData.name or songData.id)
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamSemibold
        nameLabel.TextSize = 10
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.ZIndex = 14

        local editBtn = Instance.new("TextButton", itemFrame)
        editBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
        editBtn.Position = UDim2.new(0.49, 0, 0.15, 0)
        editBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        editBtn.Text = "⚙️"
        editBtn.Font = Enum.Font.GothamBold
        editBtn.TextSize = 10
        editBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        editBtn.ZIndex = 14
        Instance.new("UICorner", editBtn).CornerRadius = UDim.new(0, 3)
        editBtn.MouseButton1Click:Connect(function() openRenameModal(songData.id, songData.name) end)

        local playBtn = Instance.new("TextButton", itemFrame)
        playBtn.Size = UDim2.new(0.18, 0, 0.7, 0)
        playBtn.Position = UDim2.new(0.63, 0, 0.15, 0)
        playBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
        playBtn.Text = "▶️ เล่น"
        playBtn.Font = Enum.Font.GothamBold
        playBtn.TextSize = 10
        playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        playBtn.ZIndex = 14
        Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0, 3)
        playBtn.MouseButton1Click:Connect(function()
            if playMusicFromId(songData.id) then
                StatusLabel.Text = "✅ เปิดเพลง: " .. songData.name
            else
                StatusLabel.Text = "❌ ไม่สามารถเล่นเพลงได้"
            end
        end)

        local delBtn = Instance.new("TextButton", itemFrame)
        delBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
        delBtn.Position = UDim2.new(0.83, 0, 0.15, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        delBtn.Text = "🗑 ลบ"
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 10
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.ZIndex = 14
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 3)
        delBtn.MouseButton1Click:Connect(function()
            removeSavedSong(songData.id)
            StatusLabel.Text = "🗑️ ลบเพลงเรียบร้อย!"
            updateSavedSongsUI()
        end)

        totalHeight = totalHeight + 36
    end
    JunkScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
end

function updateJunkViewerLive()
    if not JunkFrame.Visible then return end
    if CurrentViewMode == 4 then
        JunkTitle.Text = "⭐ SAVED SONGS LIST"
        jStroke.Color = Color3.fromRGB(0, 150, 255)
        JunkCopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        JunkTextLabel.Visible = false
        SavedContainer.Visible = true
        updateSavedSongsUI()
        return
    else
        JunkTextLabel.Visible = true
        SavedContainer.Visible = false
    end

    local outputText = ""
    if CurrentViewMode == 3 then
        JunkTitle.Text = "MY REAL-TIME AUDIO INFO"
        jStroke.Color = Color3.fromRGB(230, 0, 120)
        JunkCopyBtn.BackgroundColor3 = Color3.fromRGB(230, 0, 120)
        local soundObj, cleanId = nil, nil
        local targets = { LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack"), getPlayerVehicle(LocalPlayer) }
        for _, parent in ipairs(targets) do
            if parent then
                local descs = parent:GetDescendants()
                for _, sound in ipairs(descs) do
                    if sound:IsA("Sound") and sound.IsPlaying and sound.SoundId ~= "" then
                        cleanId = string.match(sound.SoundId, "%d+")
                        if cleanId and not BlockedIDs[cleanId] then
                            soundObj = sound
                            break
                        end
                    end
                end
                if soundObj then break end
            end
        end
        if not soundObj or not cleanId then
            outputText = "❌ ไม่พบเพลงที่กำลังเล่นอยู่บนตัวละครของคุณในขณะนี้..."
        else
            local info = getAssetInfo(cleanId)
            local currentPos = soundObj.TimePosition or 0
            local totalLength = soundObj.TimeLength or 0
            local remaining = math.max(0, totalLength - currentPos)
            local curMin = math.floor(currentPos / 60)
            local curSec = math.floor(currentPos % 60)
            local remMin = math.floor(remaining / 60)
            local remSec = math.floor(remaining % 60)
            local totMin = math.floor(totalLength / 60)
            local totSec = math.floor(totalLength % 60)
            outputText = string.format(
                "🎧 ข้อมูลเพลงบนตัวคุณ (REAL-TIME):\n\n" ..
                "📌 ชื่อเพลง: %s\n" ..
                "👤 ผู้อัพโหลด: %s\n" ..
                "🆔 Asset ID: %s\n" ..
                "🔊 ระดับเสียง (Volume): %.1f\n" ..
                "⏱️ เวลาที่เล่นไป: %02d:%02d / %02d:%02d\n" ..
                "⏳ เวลาคงเหลือ: %02d:%02d\n\n" ..
                "🔗 ลิงก์ตรง: https://www.roblox.com/library/%s",
                info.Title, info.Creator, cleanId, soundObj.Volume or 1,
                curMin, curSec, totMin, totSec, remMin, remSec, cleanId
            )
        end
    elseif CurrentSelectedPlayer then
        local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
        if not targetPlayer then return end
        local soundObjects = checkPlayerAllSounds(targetPlayer)
        if CurrentViewMode == 1 then
            JunkTitle.Text = "RAW JUNK VIEWER"
            jStroke.Color = Color3.fromRGB(140, 20, 230)
            JunkCopyBtn.BackgroundColor3 = Color3.fromRGB(140, 20, 230)
            if #soundObjects == 0 then
                outputText = "❌ ไม่พบออบเจกต์เสียงบนตัวผู้เล่นนี้"
            else
                for i, obj in ipairs(soundObjects) do
                    outputText = outputText .. string.format("[%d] ออบเจกต์: %s\nID: %s\n\n", i, obj:GetFullName(), obj.SoundId)
                end
            end
        elseif CurrentViewMode == 2 then
            JunkTitle.Text = "INSTANT LOG VIEWER"
            jStroke.Color = Color3.fromRGB(0, 200, 100)
            JunkCopyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            local finalIds, seenIds = {}, {}
            for _, soundObj in ipairs(soundObjects) do
                local rawId = soundObj.SoundId or ""
                local decoded = deepDecode(rawId)
                local searchText = (decoded ~= "" and decoded) or rawId
                local extractedIds = extractIDsFromPattern(searchText)
                if #extractedIds == 0 then
                    for num in string.gmatch(searchText, "%d+") do
                        if not BlockedIDs[num] then table.insert(extractedIds, num) end
                    end
                end
                for _, id in ipairs(extractedIds) do
                    if not seenIds[id] then
                        seenIds[id] = true
                        table.insert(finalIds, id)
                    end
                end
            end
            if #finalIds == 0 then
                outputText = "❌ ดึงค่าแล้วไม่พบ ID เพลงจริงอยู่ข้างในเลย"
            else
                outputText = "--- เจาะสำเร็จทั้งหมด " .. #finalIds .. " ID ---\n\n"
                for idx, id in ipairs(finalIds) do
                    outputText = outputText .. string.format("[%d] ID: %s\n", idx, id)
                end
            end
        end
    end

    if JunkTextLabel.Text ~= outputText then
        JunkTextLabel.Text = outputText
        local textBounds = TextService:GetTextSize(outputText, 11, Enum.Font.Code, Vector2.new(JunkScroll.AbsoluteSize.X - 15, math.huge))
        JunkTextLabel.Size = UDim2.new(1, -10, 0, textBounds.Y + 20)
        JunkScroll.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 40)
    end
end

local function refreshPlayers()
    if not ListScroll or not ListScroll:IsDescendantOf(game) then return end
    local currentPlayers = Players:GetPlayers()
    local activeMap = {}
    for _, p in ipairs(currentPlayers) do
        if p ~= LocalPlayer then
            activeMap[p] = true
            local btn = PlayerButtons[p]
            if not btn then
                btn = Instance.new("TextButton", ListScroll)
                btn.Size = UDim2.new(1, -6, 0, 28)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.ZIndex = 3
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                local bStroke = Instance.new("UIStroke", btn)
                bStroke.Color = Color3.fromRGB(40, 40, 40)
                btn.MouseButton1Click:Connect(function()
                    for _, b in pairs(PlayerButtons) do
                        if b:FindFirstChildOfClass("UIStroke") then b.UIStroke.Color = Color3.fromRGB(40, 40, 40) end
                    end
                    bStroke.Color = Color3.fromRGB(255, 215, 0)
                    CurrentSelectedPlayer = p
                    StatusLabel.Text = "เลือก: " .. p.DisplayName
                    updateJunkViewerLive()
                end)
                PlayerButtons[p] = btn
            end
            local activeSounds = checkPlayerAllSounds(p)
            btn.Text = (#activeSounds > 0 and " 🎵 " or " 👤 ") .. p.DisplayName .. " (@" .. p.Name .. ")"
            btn.TextColor3 = (#activeSounds > 0) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(230, 230, 230)
        end
    end
    for p, btn in pairs(PlayerButtons) do
        if not activeMap[p] then btn:Destroy(); PlayerButtons[p] = nil end
    end
    ListScroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

-- ==================== ปุ่มกด ====================

-- ⚡ ปุ่ม "เจาะไอดี": ใช้ BlockedIDs กรอง (ระบบเดิม)
GetIDBtn.MouseButton1Click:Connect(function()
    if CurrentSelectedPlayer then
        StatusLabel.Text = "🔍 กำลังเจาะ ID ทั้งหมด..."
        local soundObjects = checkPlayerAllSounds(CurrentSelectedPlayer)
        local finalIds, seenIds = {}, {}
        for _, soundObj in ipairs(soundObjects) do
            local rawId = soundObj.SoundId or ""
            local decoded = deepDecode(rawId)
            local searchText = (decoded ~= "" and decoded) or rawId
            local extractedIds = extractIDsFromPattern(searchText)
            if #extractedIds == 0 then
                for num in string.gmatch(searchText, "%d+") do
                    if not BlockedIDs[num] then table.insert(extractedIds, num) end
                end
            end
            for _, id in ipairs(extractedIds) do
                if not seenIds[id] then seenIds[id] = true; table.insert(finalIds, id) end
            end
        end
        if #finalIds > 0 then
            copyToClipboard(table.concat(finalIds, " "))
            StatusLabel.Text = "📋 คัดลอก " .. #finalIds .. " ID แล้ว!"
        else
            StatusLabel.Text = "❌ ไม่พบ ID ที่ใช้ได้"
        end
    else
        StatusLabel.Text = "⚠️ โปรดเลือกผู้เล่นก่อน!"
    end
end)

-- ⭐ ปุ่ม "เปิดเพลงตาม": ไม่เช็ค BlockedIDs → เปิด ID แรกที่เจอทันที + บันทึก
GetJunkBtn.MouseButton1Click:Connect(function()
    if CurrentSelectedPlayer then
        StatusLabel.Text = "🎵 กำลังยิงคำสั่งเปิดเพลงตาม..."
        local targetPlayer = Players:FindFirstChild(CurrentSelectedPlayer.Name)
        local soundObjects = checkPlayerAllSounds(targetPlayer)

        local firstCleanId = nil
        for _, soundObj in ipairs(soundObjects) do
            local rawId = soundObj.SoundId or ""
            -- ⭐ Kuki191 style: ตัด rbxassetid:// แล้วส่งทั้งก้อน
            local cleanId = string.gsub(rawId, "^rbxassetid://", "")
            if string.find(cleanId, "rbxassetid://") then
                cleanId = string.match(cleanId, "rbxassetid://(%d+)") or cleanId
            end
            -- ⭐ ไม่เช็ค BlockedIDs → เปิด ID แรกที่เจอทันที
            if cleanId ~= "" then
                firstCleanId = cleanId
                break
            end
        end

        if firstCleanId and playMusicFromId(firstCleanId) then
            addSavedSong(firstCleanId, "เพลงของ " .. CurrentSelectedPlayer.DisplayName)
            StatusLabel.Text = "✅ เปิดเพลงสำเร็จ + บันทึก: " .. firstCleanId
        else
            StatusLabel.Text = "❌ เล่นเพลงไม่สำเร็จ"
        end
    else
        StatusLabel.Text = "⚠️ โปรดเลือกชื่อผู้เล่นก่อนเปิดเพลง!"
    end
end)

ViewRawJunkBtn.MouseButton1Click:Connect(function()
    CurrentViewMode = 1; JunkFrame.Visible = true; updateJunkViewerLive()
end)
ViewInstantBtn.MouseButton1Click:Connect(function()
    CurrentViewMode = 2; JunkFrame.Visible = true; updateJunkViewerLive()
end)
MyAudioBtn.MouseButton1Click:Connect(function()
    CurrentViewMode = 3; JunkFrame.Visible = true; updateJunkViewerLive()
end)
SavedSongsBtn.MouseButton1Click:Connect(function()
    CurrentViewMode = 4; JunkFrame.Visible = true; updateJunkViewerLive()
end)

JunkCopyBtn.MouseButton1Click:Connect(function()
    if CurrentViewMode == 4 then
        local textList = {}
        for idx, song in ipairs(SavedSongs) do
            table.insert(textList, string.format("[%d] %s - ID: %s", idx, song.name, song.id))
        end
        copyToClipboard(table.concat(textList, "\n"))
        StatusLabel.Text = "📋 คัดลอกรายการเพลงที่เซฟแล้ว!"
    else
        copyToClipboard(JunkTextLabel.Text)
        StatusLabel.Text = "📋 คัดลอกเนื้อหาเรียบร้อย!"
    end
end)

JunkBackBtn.MouseButton1Click:Connect(function() JunkFrame.Visible = false end)
RefreshBtn.MouseButton1Click:Connect(refreshPlayers)

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(function(p)
    if CurrentSelectedPlayer == p then
        CurrentSelectedPlayer = nil
        StatusLabel.Text = "โปรดเลือกผู้เล่น..."
    end
    refreshPlayers()
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if not MainFrame.Visible then
        JunkFrame.Visible = false
        RenameModal.Visible = false
    else
        refreshPlayers()
    end
end)

task.spawn(function()
    while true do
        task.wait(1.5)
        if MainFrame.Visible then
            pcall(function()
                refreshPlayers()
                if JunkFrame.Visible then updateJunkViewerLive() end
            end)
        end
    end
end)

refreshPlayers()