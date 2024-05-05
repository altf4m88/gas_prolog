:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
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

% Serve static files from the 'static' directory
:- http_handler('/css/', http_reply_from_files('static/css/', []), [prefix]).

% Membuat halaman HTML untuk beranda dengan Bootstrap
home_handler(_Request) :-
    reply_html_page(
        title('Home Page'),
        [ head([
              title('Home Page'),
               meta([name(viewport), content('width=device-width, initial-scale=1')]),  % Responsive meta tag
                link([rel('stylesheet'), href('https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css')]),  % Corrected bracket here
                link([rel('stylesheet'), href('/css/style.css')])  % Link to your custom CSS file
          ]),
          body([
            % Bootstrap Jumbotron
            div([class('jumbotron text-center')],
                [ h1([class('display-4')], 'Welcome to Our Website'),
                  p('Silakan jelajahi website kami.'),
                  a([href('/tambah_profil'), class('btn btn-primary btn-lg')], 'Tambah Profil'),  % Larger Bootstrap button
                  hr([]),
                  p('Kunjungi halaman profil untuk melihat profil pengguna.')
                ]),
            % Container for images
            div([class('container mt-5')],
                [ div([class('row')],
                      [ div([class('col-md-4')],
                            [ img([src('https://picsum.photos/300/150'), class('img-fluid'), alt('Dummy Image')], [])
                            ]),
                        div([class('col-md-4')],
                            [ img([src('https://picsum.photos/300/150'), class('img-fluid'), alt('Dummy Image')], [])
                            ]),
                        div([class('col-md-4')],
                            [ img([src('https://picsum.photos/300/150'), class('img-fluid'), alt('Dummy Image')], [])
                            ])
                      ])
                ])
          ])
        ]
    ).

profil_handler(Request) :-
    http_parameters(Request, [nik(NIK, [])]),
    (   profil(NIK, Nama, Jenis_Kelamin, Umur, Alamat, Email, Keahlian)
    ->  reply_html_page(
            title('Profil Pengguna'),
            [ head([
                  title('Profil Pengguna'),
                  meta([name(viewport), content('width=device-width, initial-scale=1')]),
                  link([rel('stylesheet'), href('https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css')]),  % Corrected bracket here
                    link([rel('stylesheet'), href('/css/style.css')])  % Link to your custom CSS file
              ]),
              body([
                  div([class('container mt-5')],
                      [ div([class('jumbotron')],
                            [ h1([class('text-center')], 'Profil Pengguna'),
                              hr([])
                            ]),
                        div([class('card')],
                            [ div([class('card-body')],
                                  [ h4([class('card-title')], Nama),
                                    p([class('card-text')], ['NIK: ', NIK]),
                                    p([class('card-text')], ['Jenis Kelamin: ', Jenis_Kelamin]),
                                    p([class('card-text')], ['Umur: ', Umur]),
                                    p([class('card-text')], ['Alamat Tinggal: ', Alamat]),
                                    p([class('card-text')], ['Email: ', Email]),
                                    p([class('card-text')], ['Keahlian: ', Keahlian]),
                                    a([href('/'), class('btn btn-primary')], 'Kembali ke Beranda')
                                  ])
                            ])
                      ])
              ])
            ]
        )
    ;   reply_html_page(
            title('Profil Tidak Ditemukan'),
            [ head([
                title('Error'),
                meta([name(viewport), content('width=device-width, initial-scale-1')]),
                 link([rel('stylesheet'), href('https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css')]),  % Corrected bracket here
                link([rel('stylesheet'), href('/css/style.css')])  % Link to your custom CSS file
            ]),
              body([
                  div([class('container mt-5')],
                      [ div([class('jumbotron')],
                            [ h1([class('text-center text-danger')], 'Profil Tidak Ditemukan'),
                              p(['Profil dengan NIK ', NIK, ' tidak ditemukan.']),
                              a([href('/'), class('btn btn-secondary')], 'Kembali ke Beranda')
                            ])
                      ])
              ])
            ]
        )
    ).

% Membuat halaman HTML untuk menambah profil dengan Bootstrap
tambah_profil_handler(_Request) :-
    reply_html_page(
        title('Tambah Profil'),
        [ head([
              title('Tambah Profil'),
              meta([name(viewport), content('width=device-width, initial-scale=1')]),  % Responsive meta tag
              link([rel('stylesheet'), href('https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css')]),  % Corrected bracket here
                link([rel('stylesheet'), href('/css/style.css')])  % Link to your custom CSS file
          ]),
          body([class('container mt-5')],
              [ h1([class('text-center')], 'Tambah Profil'),
                form([action='/submit_profil', method='POST', class('form')],
                     [ div([class('form-group')],
                           ['NIK: ', input([type='text', name='nik', class('form-control')])]),
                       div([class('form-group')],
                           ['Nama: ', input([type='text', name='nama', class('form-control')])]),
                       div([class('form-group')],
                           ['Jenis Kelamin: ', input([type='text', name='jenis_kelamin', class('form-control')])]),
                       div([class('form-group')],
                           ['Umur: ', input([type='number', name='umur', class('form-control')])]),
                       div([class('form-group')],
                           ['Alamat Tinggal: ', input([name='alamat', class('form-control')])]),  % Changed to textarea for better text entry
                       div([class('form-group')],
                           ['Email: ', input([type='email', name='email', class('form-control')])]),
                       div([class('form-group')],
                           ['Keahlian: ', input([type='text', name='keahlian', class('form-control')])]),
                       input([type='submit', value='Tambah', class('btn btn-primary')])
                     ])
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
        [ head([
              title('Profil Ditambahkan'),
              meta([name(viewport), content('width=device-width, initial-scale=1')]),  % Responsive meta tag
              link([rel('stylesheet'), href('https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css')]),  % Corrected bracket here
                link([rel('stylesheet'), href('/css/style.css')])  % Link to your custom CSS file
          ]),
          body([
              div([class('container mt-5')],
                  [ div([class('alert alert-success'), role('alert')],
                        [ h4([class('alert-heading')], 'Profil Berhasil Ditambahkan!'),
                          p(['Profil dengan NIK ', NIK, ' telah berhasil ditambahkan.']),
                          hr([]),
                          p([class('mb-0')],
                            [ 'Kembali ke halaman ',
                              a([href('/profil?nik='), NIK], 'profil'),
                              ' untuk melihat detailnya.'
                            ])
                        ])
                  ])
              ])
          ]
    ).


% Menjalankan server pada port tertentu
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Contoh penggunaan: menjalankan server pada port 8000
:- initialization(server(8000)).
