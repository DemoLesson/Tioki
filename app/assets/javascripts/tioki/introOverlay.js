/*
 
  Things to do.
  
  Make the content holder resize to the size of the content..
  
  Nest a div that will resize automatically with the content then take it parameteres to resize the main content.
  Use the infintry height resize as an example of how this is done. Take out the slide down and add a overflow: hidden to the .introStuff div.
  
  make it resize width and height
*/

jQuery.fn.introOverlay = function(options){
 
// setting varibles
   
    var defaults =  {
        introLength: 10000,
        transitionSpeed: 1000,
        introAutoFade: true,
        introCloseBtn: true,
        introTransition: 'fade',
        openAnimation: true,
        cookieActive: true,
        introContent: '#intro',
        introTemplate: 'full',
        introTurnOffLights: false,
        $this: $(this)
    };
    
    
    var options = $.extend(defaults, options),
        timer = window.setTimeout,
        introMain = "#introContainer",
        introEverything = "#introOverlay, #introContainer, #introContent, #introClose";
        
    // gathering the content for overlay
    
    if(options.introContent == 'href'){
        
        timer(function(){
         
               $('.introStuff').empty().html('<div><img src="loading.gif" alt="loading" /></div>');   
        
        },10);
     
        timer(function(){
        var x = '.introStuff',
            y = options.$this.attr('class');
        
        $(x).load(options.$this.attr('href') + ' .' + y, function(){
        
          resizeContent();
        
        });
        
        },options.transitionSpeed + options.transitionSpeed*.8);
        
            
        
        
        var introContent = '';
        
    }else{
        var introContent = $(options.introContent).html();
        
    }
    
    // cookies enabled/disabled
       
    if (options.cookieActive){
        
        var introCookie = $.cookie('introCookie'),
        $cookieCreate = $.cookie('introCookie','viewed',{expires : 0});
        
    } else {
        
        var introCookie = 'not viewed';
        
    }
    
    // start main function
    
        
    if(introCookie != 'viewed'){
        
        //create the intro elements
        
        if(options.introTemplate == 'full'){
        $('body').append('<div id="introOverlay"><div id="introContainer"><div id="introContent">' + introContent + '</div></div></div>');
        $(introMain).addClass('introContainerColor');
        }else if(options.introTemplate == 'module'){
        $('body').append('<div id="introOverlay"><div id="introContainer"><div id="introContent"><div class="introBorder"></div><div class="introStuff"><div>' + introContent + '</div></div></div></div></div>');
        }
            
        // open animation
        
        if(options.openAnimation){
                
            $(introMain).hide();
            
             timer(function(){
                
                transition();
            
            },10);
            
            if(options.introTemplate == "module"){
                $('.introBorder').addClass('zeroBorder');
                
                timer(function(){
                    
                    resizeContent();
                    borderExpand();
                    btnFadeIn();
                    
                },options.transitionSpeed);
            }    
                             
        }else{
            
            resizeContent();
            timer(function(){
                
                $('#introClose, #introSwitch').show();
                
            }, 10);
            
            
        }
        
        // intro auto fade
        if(options.introAutoFade){
            
            // timing on transition
        
             autoTimer = timer(function(){
                    transition();
                    timer(function(){
                        $(introEverything).remove();
                    },options.transitionSpeed);
            },options.introLength);
            
        }
        
        // add default positions and dimensions
        
        $(introMain).addClass('introDefaultPositions introDefaultDimensions');
        
        // close btn functions
        
        if (options.introCloseBtn){
            if(options.introTemplate == 'module'){
                
                $('#introContent').append('<div id="introClose">Start Connecting</div>'); 
                
            }else{
                
                $('#introContent').append('<div id="introClose">Start Connecting</div>');
              //  $('#introClose').css('top', '10px').css('left', '10px');
                
            }
            
            
            
            //transition on click
            
            $('#introClose').bind('click', function(){
                
                transition();
                
                timer(function(){
                    
                    $(introEverything).remove();
                    
                    if(options.introAutoFade == true){
    
                        clearTimeout(autoTimer);
                        
                    }

                
                },options.transitionSpeed);
                
                 
                
            
                
            });
            
            
        }
        
        // lights btn functions
        
        if (options.introTurnOffLights){
            if(options.introTemplate == 'module'){
                $('#introContent').append('<div id="introSwitch"></div>');
                
                // toggle lights off and on
                
                $('#introSwitch').toggle(function(){
                   
                    var lightWidth = - + parseInt($('#introOverlay').width()) * 0.5,
                        lightHeightTop = - + parseInt($('#introOverlay').height()) * 0.5,
                        lightHeightBottom = - + parseInt($('#introOverlay').height()) * 0.8;
                        
                    $(this).css('background-image', 'url(images/lightsOff.png)');
                    $('.introBorder').animate({
                        left: lightWidth,
                        right: lightWidth,
                        top: lightHeightTop,
                        bottom: lightHeightBottom
                    });
                        
                        
                },function(){
                    
                    $(this).css('background-image', 'url(images/lightsOn.png)');
                    borderExpand();
                   
                
                });
            }
            
        }
        
       //transition Extras
       
       //expand borders
        
        function borderExpand(){
            
            $('.introBorder').animate({
                left: '-10px',
                right: '-10px',
                top: '-10px',
                bottom: '-10px'
            });
            
        }
        
         //resize contentbox
         
         function resizeContent(){
            var h = $('.introStuff').children('div:first').height();
            
            $('.introStuff').animate({height: h},options.transitionSpeed/2); 
          
         }
         
         // fadein buttons
         
         function btnFadeIn(){
                
                timer(function(){
                        btns.fadeIn(speed)
                },speed/2)
                
            }
        
        
        
        //finding the type of transition
        
        /* transitions need to be minimized by finding common strings and combining them into a small varible
        also the exsisting varibles below hav not been implemented throughout the whole array of functions
        combine repetitive functions*/
        
        function transition(){
            
        //basic transiton varibles
        
        var main = $(introMain),
            btns = $('#introClose, #introSwitch'),
            speed = options.transitionSpeed,
            transition = options.introTransition,
            opTran = main.is(':hidden'),
            temp = options.introTemplate,
            con = $('#introContent');
            
            if(temp == 'module'){
            
                modCon = $('.introStuff'),
                modBor = $('.introBorder');    
                
            }
            
            
            
            // transition list this is how it works (if {open animation} else {close animation})
            
            // the 'fade' transition
        
            if(transition == 'fade'){
                
                
                
                if(opTran){
                
                    main.fadeIn(speed);
                    timer(function(){
                        btns.fadeIn(speed);    
                    },speed);
                    
                }else{
                    
                    main.fadeOut(speed);
                    $cookieCreate
                    
                }
                
            // the 'slideUp' transition
                
            }else if(transition == 'slideUp'){
                
                if(opTran){
        
                    main.addClass('slideUpStart').show()
                        .animate({top: '-5%'},speed)
                        .animate({top: '2.5%'},speed/3)
                        .animate({top: '0%'},speed/2);
                    
                    timer(function(){
                        btns.fadeIn(speed);    
                    },speed);
                    
                    
                }else{
                    
                    main.animate({top: '-100%'},speed);
                    $cookieCreate
                    
                }
                
            //the 'slideLeft' transition
                
            }else if (transition == 'slideLeft'){
                
                if(opTran){
                
                main.addClass('slideLeftStart').show()
                    .animate({left: '-5%'},speed)
                    .animate({left: '2%'},speed/3)
                    .animate({left: '0%'},speed/2);
                timer(function(){
                        btns.fadeIn(speed);    
                    },speed);
                
                }else{
                    
                    main.animate({left: "-100%"},speed);
                    $cookieCreate
                    
                }
                
            // the 'slideCenter' transition
                
            }else if(transition == 'slideCenter'){
                if(temp == 'full'){
                    var o = '0%',
                        x = '100%',
                        f = '50%';
                }else if(temp == 'module'){
                    var o = '0px'; 
                }
                
                if(opTran){
                    if(temp == 'full'){
                        
                        main.addClass('slideCenterStart').show().animate({height: x, width: x, top: o, left: o},speed);
                        btns.fadeIn(speed);
                            
                    }else if(temp == 'module'){
                        
                        modCon.children().css('opacity', '0').hide();
                        
                        con.width(o).animate({width: '600px'},speed/2);
                        
                        main.show();
                        
                        timer(function(){modCon.children().slideDown(speed);},speed/4);
                        
                        timer(function(){
                            btns.fadeIn(speed);
                            modCon.children().animate({opacity: '1'},speed/2);
                        },speed/2);
                           
                    }
                        
                }else {
                    
                    if(temp == 'full'){
                    
                        main.animate({height: o, width: o, top: f, left: f},speed);    
                        
                    }else if (temp == 'module'){
                        
                        modCon.children().animate({opacity: '0'}, speed/2);
                        btns.fadeOut(speed/2);
                       
                        timer(function(){modCon.children().slideUp(speed/2);},speed/4)
                        timer(function(){  
                            con.animate({width: o},speed/2);
                        },speed/2);   
                        
                    }   
                    
                }
                
            // if nothing or invalid transition reverts to this function    
                    
            }else {
                
                if(opTran){
                
                    main.fadeIn(speed);
                    
                }else{
                    
                    main.fadeOut(speed);
                    $cookieCreate
                    
                }
                
            }
            

        }
        

    
    }
    
    
}
