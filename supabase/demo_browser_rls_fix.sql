<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Egg Mates 🥚 - Find Your Stick Partner!</title>
    
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        eggshell: '#FFFCF3',
                        yolk: '#FFB800',
                        yolkHover: '#E6A600',
                        warmOrange: '#FF7A00',
                        toastBg: '#FFF3D6',
                        eggDark: '#2E2824',
                        eggSoft: '#FAF3E0'
                    },
                    fontFamily: {
                        sans: ['Nunito', 'sans-serif'],
                    }
                }
            }
        }
    </script>
    
    <!-- Google Fonts & FontAwesome -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Canvas Confetti for Match Animation -->
    <script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>

    <style>
        body {
            font-family: 'Nunito', sans-serif;
            background-color: #FFFCF3;
            color: #2E2824;
        }
        .wooden-stick {
            background: linear-gradient(90deg, #D7CCC8 0%, #BCAAA4 50%, #A1887F 100%);
            box-shadow: inset 0 2px 4px rgba(0,0,0,0.15), 0 4px 6px rgba(0,0,0,0.05);
        }
        .egg-card {
            background: #FFFFFF;
            border: 2px solid #FFE8B6;
            box-shadow: 0 10px 25px -5px rgba(255, 184, 0, 0.1);
        }
        .chat-bubble-self {
            background: #FFE082;
            color: #2E2824;
            border-radius: 18px 18px 2px 18px;
        }
        .chat-bubble-mate {
            background: #F5F0E6;
            color: #2E2824;
            border-radius: 18px 18px 18px 2px;
        }
        .pulse-slow {
            animation: pulse 2.5s infinite;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.03); }
        }
    </style>
</head>
<body class="min-h-screen flex flex-col justify-between selection:bg-yolk selection:text-white">

    <!-- TOP NAVIGATION BAR -->
    <header class="bg-white border-b-2 border-amber-100 sticky top-0 z-40 px-4 py-3 shadow-sm">
        <div class="max-w-5xl mx-auto flex items-center justify-between">
            <div class="flex items-center space-x-2 cursor-pointer" onclick="app.navigateTo('dashboard')">
                <div class="w-10 h-10 bg-yolk rounded-full flex items-center justify-center text-2xl shadow-md transform -rotate-6">
                    🥚
                </div>
                <span class="text-2xl font-extrabold tracking-tight text-eggDark">Egg<span class="text-yolk">Mates</span></span>
            </div>

            <div id="nav-user-area" class="hidden flex items-center space-x-3">
                <div class="flex items-center space-x-2 bg-eggSoft px-3 py-1.5 rounded-full border border-amber-200">
                    <img id="nav-avatar" src="" alt="Avatar" class="w-7 h-7 rounded-full object-cover border border-amber-300">
                    <span id="nav-username" class="font-bold text-sm text-eggDark"></span>
                </div>
                <button onclick="app.logout()" class="text-xs text-amber-800 hover:text-amber-900 bg-amber-100 hover:bg-amber-200 px-3 py-2 rounded-xl transition font-bold">
                    <i class="fa-solid fa-right-from-bracket mr-1"></i> Logout
                </button>
            </div>

            <button id="nav-firebase-toggle" onclick="app.toggleFirebaseModal()" class="text-xs bg-amber-50 hover:bg-amber-100 border border-amber-200 text-amber-800 px-3 py-1.5 rounded-lg transition flex items-center gap-1 font-semibold">
                <i class="fa-solid fa-gear"></i> Setup Firebase
            </button>
        </div>
    </header>

    <!-- MAIN CONTAINER FOR VIEWS -->
    <main class="flex-grow max-w-5xl w-full mx-auto p-4 flex flex-col justify-center">

        <!-- 1. AUTHENTICATION VIEW -->
        <div id="view-auth" class="w-full max-w-md mx-auto my-6">
            <div class="egg-card rounded-3xl p-6 md:p-8">
                
                <!-- Auth Tabs -->
                <div class="flex bg-eggSoft p-1 rounded-2xl mb-6">
                    <button id="tab-login" onclick="app.switchAuthTab('login')" class="flex-1 py-2 rounded-xl font-extrabold text-sm transition bg-white shadow-sm text-eggDark">Login</button>
                    <button id="tab-signup" onclick="app.switchAuthTab('signup')" class="flex-1 py-2 rounded-xl font-extrabold text-sm transition text-gray-500 hover:text-eggDark">Sign Up</button>
                </div>

                <!-- LOGIN FORM -->
                <form id="form-login" onsubmit="app.handleLogin(event)" class="space-y-4">
                    <div>
                        <label class="block text-xs font-bold text-gray-600 uppercase mb-1">Username</label>
                        <input type="text" id="login-username" required placeholder="e.g. egglover99" class="w-full px-4 py-3 rounded-xl border-2 border-amber-100 focus:border-yolk focus:outline-none transition text-sm">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-600 uppercase mb-1">Password</label>
                        <input type="password" id="login-password" required placeholder="••••••••" class="w-full px-4 py-3 rounded-xl border-2 border-amber-100 focus:border-yolk focus:outline-none transition text-sm">
                    </div>
                    <button type="submit" class="w-full bg-yolk hover:bg-yolkHover text-white font-extrabold py-3.5 rounded-xl shadow-md transition text-base">
                        Login to Egg Mates
                    </button>
                </form>

                <!-- SIGNUP FORM -->
                <form id="form-signup" onsubmit="app.handleSignUp(event)" class="space-y-4 hidden">
                    <div>
                        <label class="block text-xs font-bold text-gray-600 uppercase mb-1">Username</label>
                        <input type="text" id="signup-username" required placeholder="e.g. crispystick" class="w-full px-4 py-3 rounded-xl border-2 border-amber-100 focus:border-yolk focus:outline-none transition text-sm">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-600 uppercase mb-1">Full Name</label>
                        <input type="text" id="signup-fullname" required placeholder="e.g. Alex Smith" class="w-full px-4 py-3 rounded-xl border-2 border-amber-100 focus:border-yolk focus:outline-none transition text-sm">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-600 uppercase mb-1">Password</label>
                        <input type="password" id="signup-password" required placeholder="At least 6 characters" class="w-full px-4 py-3 rounded-xl border-2 border-amber-100 focus:border-yolk focus:outline-none transition text-sm">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-600 uppercase mb-1">Profile Photo</label>
                        <input type="file" id="signup-photo" accept="image/*" class="w-full text-xs text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-bold file:bg-amber-100 file:text-amber-800 hover:file:bg-amber-200">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-600 uppercase mb-1">Short Bio</label>
                        <textarea id="signup-bio" rows="2" placeholder="Tell your egg mate a little about yourself!" class="w-full px-4 py-2 rounded-xl border-2 border-amber-100 focus:border-yolk focus:outline-none transition text-sm resize-none"></textarea>
                    </div>
                    <button type="submit" class="w-full bg-yolk hover:bg-yolkHover text-white font-extrabold py-3.5 rounded-xl shadow-md transition text-base">
                        Create Egg Mates Account
                    </button>
                </form>

            </div>
        </div>

        <!-- 2. DASHBOARD VIEW -->
        <div id="view-dashboard" class="hidden max-w-2xl mx-auto w-full space-y-6 my-6">
            <div class="egg-card rounded-3xl p-6 md:p-8 text-center relative overflow-hidden">
                <div class="absolute -right-8 -bottom-8 w-32 h-32 bg-amber-100 rounded-full opacity-50 pointer-events-none"></div>
                
                <span class="inline-block bg-amber-100 text-amber-800 px-4 py-1.5 rounded-full text-xs font-black uppercase tracking-wider mb-3">
                    <i class="fa-solid fa-utensils mr-1"></i> Found an Egg Puff?
                </span>
                
                <h1 class="text-3xl font-extrabold text-eggDark mb-2">Got a Secret Code?</h1>
                <p class="text-gray-600 text-sm max-w-md mx-auto mb-6">
                    Look closely at the wooden stick inside your egg puff. Enter the matching code below to reveal who has the twin stick!
                </p>

                <!-- Wooden Stick Styled Input Form -->
                <form onsubmit="app.handleCodeSubmit(event)" class="space-y-4 max-w-md mx-auto">
                    <div class="wooden-stick p-3 rounded-2xl flex items-center gap-2">
                        <i class="fa-solid fa-key text-amber-900/60 text-lg pl-2"></i>
                        <input type="text" id="code-input" required placeholder="EGG-8842" uppercase class="w-full bg-transparent font-black text-center text-xl text-amber-950 placeholder-amber-900/40 uppercase tracking-widest focus:outline-none">
                    </div>
                    <button type="submit" class="w-full bg-yolk hover:bg-yolkHover text-white font-extrabold py-3.5 rounded-2xl shadow-lg transition transform hover:-translate-y-0.5 active:translate-y-0 text-lg flex items-center justify-center gap-2">
                        <i class="fa-solid fa-wand-magic-sparkles"></i> Claim & Match Stick
                    </button>
                </form>
            </div>

            <!-- Active / Recent Matches Section -->
            <div class="egg-card rounded-3xl p-6">
                <h3 class="font-extrabold text-lg text-eggDark mb-4 flex items-center gap-2">
                    <i class="fa-solid fa-[#FFB800] fa-comments text-yolk"></i> Your Secret Connections
                </h3>
                <div id="user-connections-list" class="space-y-3">
                    <div class="text-center py-6 text-gray-400 text-sm italic">
                        No active codes yet! Enter a secret code above to get started.
                    </div>
                </div>
            </div>
        </div>

        <!-- 3. WAITING STATE VIEW -->
        <div id="view-waiting" class="hidden max-w-md mx-auto w-full my-6 text-center">
            <div class="egg-card rounded-3xl p-8 space-y-6">
                <div class="w-24 h-24 bg-amber-100 rounded-full flex items-center justify-center mx-auto pulse-slow">
                    <span class="text-5xl animate-bounce">🥚</span>
                </div>
                <div>
                    <h2 class="text-2xl font-extrabold text-eggDark mb-2">Waiting for your Egg Mate!</h2>
                    <p class="text-sm text-gray-600">Your stick code <span id="waiting-code-display" class="font-black text-amber-800 bg-amber-100 px-2 py-0.5 rounded-md"></span> is registered.</p>
                </div>
                <div class="p-4 bg-eggSoft rounded-2xl border border-amber-200 text-xs text-amber-900 space-y-2 text-left">
                    <p class="font-bold flex items-center gap-1.5"><i class="fa-solid fa-circle-info text-yolk"></i> What happens next?</p>
                    <p>Keep your stick safe! As soon as someone enters the exact same code from their egg puff, this screen will instantly transform and reveal their profile.</p>
                </div>
                <button onclick="app.navigateTo('dashboard')" class="text-xs font-bold text-gray-500 hover:text-eggDark underline">
                    Return to Dashboard
                </button>
            </div>
        </div>

        <!-- 4. PROFILE DUAL REVEAL MATCH VIEW -->
        <div id="view-match" class="hidden max-w-3xl mx-auto w-full my-6 space-y-6">
            <div class="text-center space-y-2">
                <span class="bg-yolk text-white font-black text-xs px-4 py-1.5 rounded-full uppercase tracking-wider inline-block">
                    🎉 It's a Perfect Match!
                </span>
                <h1 class="text-3xl font-extrabold text-eggDark">You Found Your Egg Mate!</h1>
                <p class="text-sm text-gray-600">Both secret codes matched on the wooden stick.</p>
            </div>

            <!-- Side-By-Side Profile Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 relative">
                
                <!-- Connector Icon in Center -->
                <div class="hidden md:flex absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-10 w-12 h-12 bg-yolk text-white rounded-full items-center justify-center text-xl shadow-lg border-4 border-white">
                    <i class="fa-solid fa-heart"></i>
                </div>

                <!-- User Profile Card -->
                <div class="egg-card rounded-3xl p-6 text-center space-y-3">
                    <span class="text-xs font-bold uppercase tracking-wider text-amber-800 bg-amber-100 px-3 py-1 rounded-full">You</span>
                    <img id="match-user-photo" src="" class="w-24 h-24 rounded-full mx-auto object-cover border-4 border-amber-200 shadow">
                    <div>
                        <h3 id="match-user-name" class="font-extrabold text-lg text-eggDark"></h3>
                        <p id="match-user-handle" class="text-xs text-amber-800 font-semibold"></p>
                    </div>
                    <p id="match-user-bio" class="text-xs text-gray-600 italic bg-eggSoft p-3 rounded-2xl border border-amber-100"></p>
                </div>

                <!-- Egg Mate Profile Card -->
                <div class="egg-card rounded-3xl p-6 text-center space-y-3 border-2 border-yolk shadow-xl">
                    <span class="text-xs font-bold uppercase tracking-wider text-white bg-yolk px-3 py-1 rounded-full">Your Egg Mate</span>
                    <img id="match-mate-photo" src="" class="w-24 h-24 rounded-full mx-auto object-cover border-4 border-yolk shadow">
                    <div>
                        <h3 id="match-mate-name" class="font-extrabold text-lg text-eggDark"></h3>
                        <p id="match-mate-handle" class="text-xs text-amber-800 font-semibold"></p>
                    </div>
                    <p id="match-mate-bio" class="text-xs text-gray-600 italic bg-eggSoft p-3 rounded-2xl border border-amber-100"></p>
                </div>
            </div>

            <div class="text-center pt-2">
                <button onclick="app.startChatFromMatch()" class="bg-yolk hover:bg-yolkHover text-white font-extrabold px-8 py-4 rounded-2xl shadow-xl transition transform hover:scale-105 text-lg inline-flex items-center gap-3">
                    <i class="fa-solid fa-paper-plane"></i> Start Chatting Now
                </button>
            </div>
        </div>

        <!-- 5. REAL-TIME CHAT VIEW -->
        <div id="view-chat" class="hidden max-w-3xl mx-auto w-full my-4 flex-grow flex flex-col h-[75vh]">
            <div class="egg-card rounded-3xl flex flex-col h-full overflow-hidden shadow-xl">
                
                <!-- Chat Header -->
                <div class="bg-eggSoft px-6 py-4 border-b border-amber-200 flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <button onclick="app.navigateTo('dashboard')" class="text-amber-800 hover:text-amber-950 pr-2">
                            <i class="fa-solid fa-arrow-left text-lg"></i>
                        </button>
                        <img id="chat-header-avatar" src="" class="w-10 h-10 rounded-full object-cover border-2 border-yolk">
                        <div>
                            <h3 id="chat-header-name" class="font-extrabold text-eggDark text-sm"></h3>
                            <p id="chat-header-code" class="text-xs text-amber-800 font-semibold"></p>
                        </div>
                    </div>
                    <span class="text-xs bg-emerald-100 text-emerald-800 font-bold px-2.5 py-1 rounded-full flex items-center gap-1">
                        <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span> Live Chat
                    </span>
                </div>

                <!-- Messages Stream Area -->
                <div id="chat-messages-container" class="flex-grow p-4 overflow-y-auto space-y-3 bg-amber-50/30">
                    <div class="text-center text-xs text-gray-400 my-4">
                        🔒 End-to-end egg mates secret match created. Say hi!
                    </div>
                </div>

                <!-- Message Input Bar -->
                <form onsubmit="app.handleSendMessage(event)" class="p-3 bg-white border-t border-amber-100 flex items-center gap-2">
                    <input type="text" id="chat-input" required placeholder="Type your message..." class="flex-grow px-4 py-3 rounded-2xl border-2 border-amber-100 focus:border-yolk focus:outline-none transition text-sm">
                    <button type="submit" class="bg-yolk hover:bg-yolkHover text-white p-3.5 rounded-2xl shadow transition flex items-center justify-center">
                        <i class="fa-solid fa-paper-plane text-lg"></i>
                    </button>
                </form>
            </div>
        </div>

    </main>

    <!-- FOOTER -->
    <footer class="text-center py-4 text-xs text-amber-900/60 font-semibold">
        Egg Mates &copy; 2026 &bull; Connecting Wooden Stick Twin Codes Everywhere 🥚
    </footer>

    <!-- TOAST NOTIFICATION POPUP -->
    <div id="toast" class="fixed bottom-6 right-6 max-w-sm bg-toastBg border-2 border-amber-300 text-amber-950 px-4 py-3 rounded-2xl shadow-xl transform translate-y-24 opacity-0 transition-all duration-300 z-50 flex items-center gap-3">
        <i id="toast-icon" class="fa-solid fa-circle-info text-yolk text-xl"></i>
        <span id="toast-message" class="text-xs font-extrabold"></span>
    </div>

    <!-- FIREBASE SETUP CONFIG MODAL -->
    <div id="modal-firebase" class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4 hidden">
        <div class="bg-white rounded-3xl max-w-md w-full p-6 space-y-4 shadow-2xl border-2 border-amber-200">
            <div class="flex justify-between items-center">
                <h3 class="font-extrabold text-lg text-eggDark"><i class="fa-solid fa-fire text-amber-500 mr-2"></i> Firebase Credentials</h3>
                <button onclick="app.toggleFirebaseModal()" class="text-gray-400 hover:text-gray-600"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <p class="text-xs text-gray-600">
                Paste your Firebase Project Configuration object below to use live Firebase Firestore & Auth. By default, app runs seamlessly in