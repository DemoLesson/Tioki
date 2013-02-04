/*
 
  Things to do.
  
  Make the content holder resize to the size of the content..
  
  Nest a div that will resize automatically with the content then take it parameteres to resize the main content.
  Use the infintry height resize as an example of how this is done. Take out the slide down and add a overflow: hidden to the .completionStuff div.
  
  make it resize width and height
*/

jQuery.fn.completionOverlay = function(options){
 
// setting varibles
   
    var defaults =  {
        completionLength: 10000,
        transitionSpeed: 1000,
        completionAutoFade: true,
        completionCloseBtn: true,
        completionTransition: 'fade',
        openAnimation: true,
        cookieActive: true,
        completionContent: '#completion',
        completionTemplate: 'full',
        completionTurnOffLights: false,
        $this: $(this)
    };
    
    
    var options = $.extend(defaults, options),
        timer = window.setTimeout,
        completionMain = "#completionContainer",
        completionEverything = "#completionOverlay, #completionContainer, #completionContent, #completionClose";
        
    // gathering the content for overlay
    
    if(options.completionContent == 'href'){
        
        timer(function(){
         
               $('.completionStuff').empty().html('<div><img src="loading.gif" alt="loading" /></div>');   
        
        },10);
     
        timer(function(){
        var x = '.completionStuff',
            y = options.$this.attr('class');
        
        $(x).load(options.$this.attr('href') + ' .' + y, function(){
        
          resizeContent();
        
        });
        
        },options.transitionSpeed + options.transitionSpeed*.8);
        
            
        
        
        var completionContent = '';
        
    }else{
        var completionContent = $(options.completionContent).html();
        
    }
    
    // cookies enabled/disabled
       
    if (options.cookieActive){
        
        var completionCookie = $.cookie('completionCookie'),
        $cookieCreate = $.cookie('completionCookie','viewed',{expires : 0});
        
    } else {
        
        var completionCookie = 'not viewed';
        
    }
    
    // start main function
    
        
    if(completionCookie != 'viewed'){
        
        //create the completion elements
        
        if(options.completionTemplate == 'full'){
        $('body').append('<div id="completionOverlay"><div id="completionContainer"><div id="completionContent">' + completionContent + '</div></div></div>');
        $(completionMain).addClass('completionContainerColor');
        }else if(options.completionTemplate == 'module'){
        $('body').append('<div id="completionOverlay"><div id="completionContainer"><div id="completionContent"><div class="completionBorder"></div><div class="completionStuff"><div>' + completionContent + '</div></div></div></div></div>');
        }
            
        // open animation
        
        if(options.openAnimation){
                
            $(completionMain).hide();
            
             timer(function(){
                
                transition();
            
            },10);
            
            if(options.completionTemplate == "module"){
                $('.completionBorder').addClass('zeroBorder');
                
                timer(function(){
                    
                    resizeContent();
                    borderExpand();
                    btnFadeIn();
                    
                },options.transitionSpeed);
            }    
                             
        }else{
            
            resizeContent();
            timer(function(){
                
                $('#completionClose, #completionSwitch').show();
                
            }, 10);
            
            
        }
        
        // completion auto fade
        if(options.completionAutoFade){
            
            // timing on transition
        
             autoTimer = timer(function(){
                    transition();
                    timer(function(){
                        $(completionEverything).remove();
                    },options.transitionSpeed);
            },options.completionLength);
            
        }
        
        // add default positions and dimensions
        
        $(completionMain).addClass('completionDefaultPositions completionDefaultDimensions');
        
        // close btn functions
        
        if (options.completionCloseBtn){
            if(options.completionTemplate == 'module'){
                
                $('#completionContent').append('<div id="completionClose">Test</div>'); 
                
            }else{
                
                $('#completionContent').append('<div id="completionClose"><img src="/assets/tioki/icons/close.png" style="width:20px"></div>');
              //  $('#completionClose').css('top', '10px').css('left', '10px');
                
            }
            
            
            
            //transition on click
            
            $('#completionClose').bind('click', function(){
                
                transition();
                
                timer(function(){
                    
                    $(completionEverything).remove();
                    
                    if(options.completionAutoFade == true){
    
                        clearTimeout(autoTimer);
                        
                    }

                
                },options.transitionSpeed);
                
                 
                
            
                
            });
            
            $('#completionContainer').bind('click', function(e){
							if (e.target.id === 'completionContainer'){
								$('#completionClose').click();
							}
            });
            
        }
        
        // lights btn functions
        
        if (options.completionTurnOffLights){
            if(options.completionTemplate == 'module'){
                $('#completionContent').append('<div id="completionSwitch"></div>');
                
                // toggle lights off and on
                
                $('#completionSwitch').toggle(function(){
                   
                    var lightWidth = - + parseInt($('#completionOverlay').width()) * 0.5,
                        lightHeightTop = - + parseInt($('#completionOverlay').height()) * 0.5,
                        lightHeightBottom = - + parseInt($('#completionOverlay').height()) * 0.8;
                        
                    $(this).css('background-image', 'url(images/lightsOff.png)');
                    $('.completionBorder').animate({
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
            
            $('.completionBorder').animate({
                left: '-10px',
                right: '-10px',
                top: '-10px',
                bottom: '-10px'
            });
            
        }
        
         //resize contentbox
         
         function resizeContent(){
            var h = $('.completionStuff').children('div:first').height();
            
            $('.completionStuff').animate({height: h},options.transitionSpeed/2); 
          
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
        
        var main = $(completionMain),
            btns = $('#completionClose, #completionSwitch'),
            speed = options.transitionSpeed,
            transition = options.completionTransition,
            opTran = main.is(':hidden'),
            temp = options.completionTemplate,
            con = $('#completionContent');
            
            if(temp == 'module'){
            
                modCon = $('.completionStuff'),
                modBor = $('.completionBorder');    
                
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
