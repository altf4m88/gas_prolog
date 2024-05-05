:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/html_write)).
:- use_module(library(persistency)).

% Inisialisasi basis data dengan field tambahan
:- persistent(
    profil(nik:atom, nama:atom, jenis_kelamin:atom, umur:integer,
           alamat:atom, email:atom, keahlian:atom)
).

% Pilih lokasi penyimpanan basis data
:- db_attach('profil.db', []).

% Handler untuk halaman beranda
:- http_handler(root(.), home_handler, []).

% Handler untuk halaman profil
:- http_handler(root(profil), profil_handler, []).

% Handler untuk halaman tambah profil
:- http_handler(root(tambah_profil), tambah_profil_handler, []).

% Membuat halaman HTML untuk beranda
home_handler(_Request) :-
    reply_html_page(
        title('Beranda'),
        [ h1('Selamat Datang di Website Profil'),
          p('Silakan jelajahi website kami.'),
          p('Kunjungi halaman profil untuk melihat profil pengguna.'),
          p('Untuk menambahkan profil, kunjungi halaman tambah profil.')
        ]
    ).

% Membuat halaman HTML untuk profil
profil_handler(Request) :-
    http_parameters(Request, [nik(NIK, [])]),
    (   profil(NIK, Nama, Jenis_Kelamin, Umur, Alamat, Email, Keahlian)
    ->  reply_html_page(
            title('Profil Pengguna'),
            [ h1('Profil Pengguna'),
              p(['NIK: ', NIK]),
              p(['Nama: ', Nama]),
              p(['Jenis Kelamin: ', Jenis_Kelamin]),
              p(['Umur: ', Umur]),
              p(['Alamat Tinggal: ', Alamat]),
              p(['Email: ', Email]),
              p(['Keahlian: ', Keahlian])
            ]
        )
    ;   reply_html_page(
            title('Profil Tidak Ditemukan'),
            [ h1('Profil Tidak Ditemukan'),
              p(['Profil dengan NIK ', NIK, ' tidak ditemukan.'])
            ]
        )
    ).

% Membuat halaman HTML untuk menambah profil
tambah_profil_handler(_Request) :-
    reply_html_page(
        title('Tambah Profil'),
        [ h1('Tambah Profil'),
          form([action='/submit_profil', method='POST'],
               [ p(['NIK: ', input([type='text', name='nik'])]),
                 p(['Nama: ', input([type='text', name='nama'])]),
                 p(['Jenis Kelamin: ', input([type='text', name='jenis_kelamin'])]),
                 p(['Umur: ', input([type='number', name='umur'])]),
                 p(['Alamat Tinggal: ', input([name='alamat'])]),
                 p(['Email: ', input([type='email', name='email'])]),
                 p(['Keahlian: ', input([type='text', name='keahlian'])]),
                 p(input([type='submit', value='Tambah']))
               ])
        ]
    ).

% Handler untuk menyimpan profil yang ditambahkan
:- http_handler(root(submit_profil), submit_profil_handler, [method(post)]).

submit_profil_handler(Request) :-
     http_parameters(Request,
                    [ nik(NIK, []), nama(Nama, []), jenis_kelamin(Jenis_Kelamin, []),
                      umur(UmurAtom, []), alamat(Alamat, []), email(Email, []), 
                      keahlian(Keahlian, []) ]),
    atom_number(UmurAtom, Umur),  % Convert the atom to an integer
    assert_profil(NIK, Nama, Jenis_Kelamin, Umur, Alamat, Email, Keahlian),
    reply_html_page(
        title('Profil Ditambahkan'),
        [ h1('Profil Ditambahkan'),
          p(['Profil dengan NIK ', NIK, ' berhasil ditambahkan.']),
          p('Kembali ke halaman '),
          a([href('/profil?nik='), NIK], 'profil'),
          p('.')
        ]
    ).

% Menjalankan server pada port tertentu
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Contoh penggunaan: menjalankan server pada port 8000
:- initialization(server(8000)).
