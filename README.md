# Grafit


Komponent [USI][1] wspomagający zapisy na przedmioty obieralne przez studentów wydziału. 

##### Użytkownicy systemu:
* studenci - mogą logować się na swoje konto i mają dostęp do panelu użytkownika, zapisują się na przedmioty obieralne;
* obsługa dziekanatu - zarządza przedmiotów obieralnych, generuje raporty; uprawnienia administracyjne per wydział;



##### Zapisy studentów na przedmioty obieralne:
1. Osoba uprawniona w systemie dodaje przedmioty obieralne do wyboru. Każdy przedmiot jest przypisany do osoby odpowiedzialnej oraz studiów (1 lub więcej), z których studenci muszą dokonać zapisu. Rodzaje przedmiotów obieralnych:

    * moduły obieralne do wyboru (N przedmiotów z M przedmiotów w puli do wyboru);
    * bloki obieralne do wyboru (N bloków z M bloków w puli do wyboru) &ndash; blok obieralny to grupa kilku przedmiotów;

    W przypadku wyborów bloków obieralnych można narzucić dodatkowy warunek zapisów studentów w/g średniej ze studiów oraz zgromadzonych punktów ECTS.

2. W dniu ustalonym przez osobę z uprawnieniami administratora, otwierane są zapisy na przedmioty obieralne. W zależności od rodzaju przedmiotu ,liczy się kolejność zapisów lub średniej ze studiów oraz zgromadzone punktów ECTS.
3. W dniu określonym przez osobę z uprawnieniami administratora, zamykane są zapisy na przedmioty obieralne. 
4. Studenci wyniki zapisów poznają w zależności od rodzaju przedmiotu obieralnego:
    * w przypadku modułów obieralnych do wyboru decyduje kolejność zapisów, zatem wyniki znane są po chwili;
    * wyniki zapisów bloków obieralnych zależą od bardziej złożonego algorytmu szeregowania zapisów, dlatego też wynik znany jest dopiero po zakończeniu zapisów.

##### Eksport danych:

Dostępne raporty:

* tylko zapisani studenci &ndash; format XLS;
* wszyscy dodani studenci w systemie (dzięki temu wiadomo, kto się nie zapisał) &ndash; format XLS;
* lista przedmiotów obieralnych w zależności od filtrów (rodzaj przedmiotu, studia, semestr studiów, semestr wyboru, rocznik) &ndash; format XLS/PDF;


# Demo

Wersja demonstracyjna systemu dostępna jest [tutaj][2].

Przykładowi użytkownicy:

* osoba z uprawnieniami wydziałowego administratora:
Login: `szef@at.edu`

* osoba z uprawnieniami kierownika katedry:
Login: `kierownik@at.edu`

* osoba z uprawnieniami promotora:
Login: `torpeda@at.edu`

* osoba z uprawnieniami studenta:
Login: `babel@at.edu `

Hasło do wszystkich kont: `123qweasdzxc`.



# Wymagania:

* GNU/Linux - praktycznie dowolna dystrybucja, zalecana GNU/Debian
* Ruby >= 2.0
* Ruby on Rails = 4.0.4
* PostgreSQL >= 9.0
* Redis >= 2.8.4
* Memcached >= 1.4.14


# Instalacja

Patrz [USI][1].

Jeżeli potrzebujesz wsparcia przy wdrożeniu systemu, zapraszamy do kontaktu z nami.

# Licencja

AGPL

Patrz plik LICENCE

# Kontakt

biuro@opensoftware.pl

[1]: https://github.com/Opensoftware/USI-Core