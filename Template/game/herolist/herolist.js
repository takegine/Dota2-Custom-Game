

var app_data = {
    strength : HeroList_Strength,
    agility :  HeroList_Agility,
    intelligence : HeroList_Intelligence,
    selective : {},     // 选择列表
    code : '',
}

var app = new Vue({
    el: '#app',
    data: app_data,
    methods: {
        get_image: function(hero) {
            var name = hero.name;
            name = name.split(' ').join('_')
            return 'herolist/icon/150px-' + name + '_icon.png'
        },
        get_name: function(hero){
            var JsSrc =(navigator.language || navigator.browserLanguage).toLowerCase();
            if(JsSrc.indexOf('zh')>=0) // 假如浏览器语言是中文
            {
                return hero.name_sc
            }
            else if(JsSrc.indexOf('en')>=0) // 假如浏览器语言是英文
            {
                return hero.name                
            }
            else    // 假如浏览器语言是其它语言
            {
                return hero.name
            }        
        },
        is_select: function(hero){
            var name = hero.name
            return app_data.selective[name]
        },
        on_click: function(hero){
            var name = hero.name
            var is_select = app_data.selective[name]
            if (is_select) {
                // app_data.selective[name] = null 
                Vue.set(app_data.selective, name, null)  
            }else{
                // app_data.selective[name] = hero
                Vue.set(app_data.selective, name, hero)  
            }
            this.export_code()
        },
        find_hero_by_name_game(name_game){
            for (let i = 0; i < app_data.agility.length; i++) {
                var hero = app_data.agility[i];
                if (hero.name_game === name_game) {
                    return hero
                }
            }
            for (let i = 0; i < app_data.strength.length; i++) {
                var hero = app_data.strength[i];
                if (hero.name_game === name_game) {
                    return hero
                }
            }
            for (let i = 0; i < app_data.intelligence.length; i++) {
                var hero = app_data.intelligence[i];
                if (hero.name_game === name_game) {
                    return hero
                }
            }

            return null
        },
        import_code: function(){
            var selective = {}

            var code = app_data.code
            if (code) { 
                var uidArr = code.split(/[(\r\n)\r\n]+/)
                for (var i = 0; i < uidArr.length; i++) {
                    var line = uidArr[i];
                    var line_arr = line.trim().split(/\s+/)
                    // console.log(line_arr)
                    if (line_arr.length == 2) {
                        var hero_name_game = line_arr[0]
                        var hero_active = line_arr[1]
                        if (hero_active !== '"0"') {
                            hero_name_game = hero_name_game.replace('"', "")  
                            hero_name_game = hero_name_game.replace('"', "") 
                            var hero = this.find_hero_by_name_game(hero_name_game)
                            if (hero) {
                            //    Vue.set(app_data.selective, hero.name, hero) 
                                selective[hero.name] = hero
                            }
                        }
                    }
                }
            }


            app_data.selective = selective
        },
        export_code: function(){
            var code = '"CustomHeroList" \n{'

            for (var key in app_data.selective) {
                if (app_data.selective.hasOwnProperty(key)) {
                    var hero = app_data.selective[key];
                    if (hero) {
                        code += '\n'
                        code += '    "' + hero.name_game + '"' + '    "1"'
                    }
                }
            }
            
            code += '\n}'

            app_data.code = code
        },
    }
})

