
recommApp = angular
    .module('recommender', ['ngAnimate', 'ngRoute', 'ngCookies', 'ui.bootstrap'])
    .config(['$routeProvider', function($routeProvider) {
        $routeProvider.
          when('/home', {templateUrl: 'partials/steamid.html', controller: SteamIdCtrl }).
          when('/about', {templateUrl: 'partials/about.html' }).
          when('/contact', {templateUrl: 'partials/contact.html', controller: ContactCtrl }).
          when('/success', {templateUrl: 'partials/success.html' }).
          when('/private', {templateUrl: 'partials/private.html'}).
          when('/connection', {templateUrl: 'partials/connection.html'}).
          when('/profile', {templateUrl: 'partials/profile.html', controller: ProfileCtrl }).
          when('/profile/:id', {templateUrl: 'partials/profile.html', controller: ProfileCtrl }).
          when('/recomms', {templateUrl: 'partials/recomms.html', controller: RecommsCtrl }).
          when('/steamid', {templateUrl: 'partials/steamid.html', controller: SteamIdCtrl }).
          when('/games', { templateUrl: 'partials/games.html', controller: GamesCtrl}).
          when('/game/:id', { templateUrl: 'partials/game.html', controller: GameCtrl}).
          when('/genres', { templateUrl: 'partials/genres.html', controller: GenresCtrl }).
          when('/genre/:id', { templateUrl: 'partials/genre.html', controller: GenreCtrl }).
          otherwise({redirectTo: '/home'});
    }]);

recommApp.factory('AppLoading', function($rootScope) {
    var timer;
    return {
        loading : function() {
            clearTimeout(timer);
            $rootScope.status = 'loading';
            if (!$rootScope.$$phase) $rootScope.$apply();
        },
        ready : function(delay) {
            function ready() {
                $rootScope.status = 'ready';
                if (!$rootScope.$$phase) $rootScope.$apply();
            }

            clearTimeout(timer);
            delay = delay == null ? 5000 : false;
            if (delay) {
                timer = setTimeout(ready, delay);
            } else {
                ready();
            }
        }
    };
});

recommApp.directive('ngEnter', function () {
    return function (scope, element, attrs) {
        element.bind("keydown keypress", function (event) {
            if(event.which === 13) {
                scope.$apply(function (){
                    scope.$eval(attrs.ngEnter);
                });

                event.preventDefault();
            }
        });
    };
});

recommApp.directive('game', function() {
    return {
        restrict: 'E',
        templateUrl: 'partials/game-directive.html'
    };
});

recommApp.directive('profile', function() {
    return {
        restrict: 'E',
        templateUrl: 'partials/header-directive.html'
    };
});

recommApp.factory('ProfileCache', function($cacheFactory) {
   return $cacheFactory('profile');
});

recommApp.factory('RecommsCache', function($cacheFactory) {
   return $cacheFactory('recomms');
});

recommApp.service('SteamIdService', function($http, $cookies) {
    var steamId = 'Steam Id';
    var steamDetails = {};
    var ready = false;
    var stateLookup = {
        0 : 'Offline', 1 : 'Online', 2 : 'Busy', 3 : 'Away',
        4 : 'Snooze', 5 : 'Looking to trade', 6 : 'Looking to play'
    };

    this.isReady = function() {
        return ready;
    };

    this.reset = function() {
        steamId = 'Steam Id';
        steamDetails = '';
        delete $cookies.steamId;
        ready = false;
    };

    this.setSteamId = function(newSteamId, newSteamDetails) {
        steamId = newSteamId;
        steamDetails = newSteamDetails;
        steamDetails.stateString = stateLookup[steamDetails['personastate']]
        $cookies.steamId = steamId;
        $cookies.steamDetails = JSON.stringify(steamDetails);
        ready = true;
    };

    this.getSteamId = function() {
        return steamId;
    };

    this.getSteamDetails = function() {
        return steamDetails;
    };

    this.init = function() {
        var cookieSteamId = $cookies.steamId;
        var cookieSteamDetails = $cookies.steamDetails;
        if (cookieSteamId && cookieSteamDetails) {
            steamId = cookieSteamId;
            steamDetails = JSON.parse(cookieSteamDetails);
            ready = true;
        } else {
            steamId = 'Steam Id';
            steamDetails = {};
            ready = false;
        }
    };

    this.init();
});

recommApp.service("GamesService", function(AppLoading) {
    this.getSize = function(state, http, url) {
        AppLoading.loading();
        http.get(url).
            success(function (data) {
                state.pageCount = data['pageCount'];
                state.gameCount = data['gameCount'];
                AppLoading.ready(5000);
            });
    };

    this.getGames = function(state, http, prefix, pageNo, order, fn) {
        state.pageNo = pageNo;
        state.order = order;
        http.get(prefix+'?page='+pageNo+'&order='+order).success(fn);
    };
});
