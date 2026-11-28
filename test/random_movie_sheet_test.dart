import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cineshelf/models/movie.dart';
import 'package:cineshelf/widgets/random_movie_sheet.dart';

const Movie _movie = Movie(
  id: 7,
  title: 'Film Uji',
  year: 0,
  rating: 0,
  posterUrl: '',
  overview: '  ',
  genres: [],
);

Widget _wrap(Future<Movie?> Function() loadMovie) {
  return MaterialApp(
    home: Scaffold(body: RandomMovieSheet(loadMovie: loadMovie)),
  );
}

ButtonStyleButton _button(WidgetTester tester, String label) {
  return tester.widget<ButtonStyleButton>(
    find.ancestor(
      of: find.text(label),
      matching: find.bySubtype<ButtonStyleButton>(),
    ),
  );
}

void main() {
  testWidgets('Tombol sheet nonaktif saat memuat', (tester) async {
    final completer = Completer<Movie?>();
    await tester.pumpWidget(_wrap(() => completer.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_button(tester, 'Acak Lagi').enabled, isFalse);
    expect(_button(tester, 'Lihat Detail').enabled, isFalse);

    completer.complete(_movie);
    await tester.pump();

    expect(_button(tester, 'Acak Lagi').enabled, isTrue);
    expect(_button(tester, 'Lihat Detail').enabled, isTrue);
  });

  testWidgets('Sheet menampilkan data kosong dengan label bawaan', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(() async => _movie));
    await tester.pump();

    expect(find.text('Film Uji'), findsOneWidget);
    expect(find.text('TBA'), findsOneWidget);
    expect(find.text('Belum dinilai'), findsOneWidget);
    expect(find.text('Sinopsis belum tersedia.'), findsOneWidget);
  });

  testWidgets('Sheet menampilkan pesan gagal dan tombol coba lagi', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _wrap(() async {
        calls++;
        if (calls == 1) throw Exception('gagal');
        return _movie;
      }),
    );
    await tester.pump();

    expect(find.text('Gagal memuat film acak'), findsOneWidget);
    expect(_button(tester, 'Lihat Detail').enabled, isFalse);

    await tester.tap(find.text('Coba lagi'));
    await tester.pump();

    expect(calls, 2);
    expect(find.text('Film Uji'), findsOneWidget);
  });

  testWidgets('Lihat Detail menutup sheet dan mengembalikan id film', (
    tester,
  ) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showRandomMovieSheet(context, () async => _movie);
            },
            child: const Text('Buka'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Detail'));
    await tester.pumpAndSettle();

    expect(result, 7);
    expect(find.text('Film Uji'), findsNothing);
  });
}
