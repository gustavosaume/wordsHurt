function TTS() {
  var speech = new SpeechSynthesisUtterance();
  this.say = function(str) {
    if (!('speechSynthesis' in window)) {return; }

    if (window.speechSynthesis.speaking) {
      console.log("SPEAKING");
    } 
    else {
      try {
        speech.text = str;
        speech.lang = 'en-US';
        speech.rate = 1.5;
        speech.volume = 1; 
        speech.pitch = 1;
        
        var voices = window.speechSynthesis.getVoices();
        if (voices.length > 30) {
          speech.voice = voices[30];   
        }
        
        speech.voiceURI = 'native';
        
        window.speechSynthesis.speak(speech);  
      }
      catch(e) {
        console.log("SPEECH IMPEDIMENT");
      }
      
    }
  };
}
