:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).

% Definisikan fakta-fakta tentang profil
profil(john, 'John Doe', 'john@example.com', 'Software Engineer').
profil(jane, 'Jane Smith', 'jane@example.com', 'Data Scientist').
profil(jim, 'Jim Morrison', 'jm@example.com', 'Singer').
profil(jimi_hendrix, 'Jimi Hendrix', 'jimihendrix@example.com', 'Guitarist').

% Handler untuk halaman profil
:- http_handler(root(profile), profile_handler, []).

% Membuat halaman HTML untuk profil pengguna dengan CSS
profile_handler(_Request) :-
    format('Content-type: text/html~n~n'),
    format('<html>~n', []),
    format('<head><title>Profil Pengguna</title>~n', []),
    format('<style>~n\
            body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 40px; }~n\
            h1 { color: #333; }~n\
            ul { list-style-type: none; padding: 0; }~n\
            li { margin: 10px 0; }~n\
            a { color: #06c; }~n\
            </style></head>~n', []),
    format('<body>~n', []),
    format('<h1>Profil Pengguna</h1>~n', []),
    format('<ul>~n', []),

    profil(Username, Name, Email, Occupation),
    format('<li><b>Nama:</b> ~w</li>~n', [Name]),
    format('<li><b>Username:</b> ~w</li>~n', [Username]),
    format('<li><b>Email:</b> <a href="mailto:~w">~w</a></li>~n', [Email, Email]),
    format('<li><b>Pekerjaan:</b> ~w</li>~n', [Occupation]),
    fail.
profile_handler(_Request) :-
    format('</ul>~n', []),
    format('<br>', []),
    format('</body></html>~n', []).

% Menjalankan server pada port tertentu
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Contoh penggunaan: menjalankan server pada port 8000
:- initialization(server(8000)).
