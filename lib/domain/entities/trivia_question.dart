class TriviaQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? fact;

  const TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.fact,
  });
}

const triviaQuestions = [
  TriviaQuestion(
    question: 'Which country won the first FIFA World Cup in 1930?',
    options: ['Argentina', 'Uruguay', 'Brazil', 'Italy'],
    correctIndex: 1,
    fact: 'Uruguay hosted and won the inaugural tournament.',
  ),
  TriviaQuestion(
    question: 'Who is the all-time top scorer in World Cup history?',
    options: ['Ronaldo', 'Miroslav Klose', 'Pelé', 'Lionel Messi'],
    correctIndex: 1,
    fact: 'Klose scored 16 goals across four tournaments (2002-2014).',
  ),
  TriviaQuestion(
    question: 'How many teams will play in the 2026 World Cup?',
    options: ['32', '40', '48', '64'],
    correctIndex: 2,
    fact: '2026 is the first edition with 48 teams.',
  ),
  TriviaQuestion(
    question: 'Which country has won the most World Cups?',
    options: ['Germany', 'Argentina', 'Italy', 'Brazil'],
    correctIndex: 3,
    fact: 'Brazil has 5 titles (1958, 1962, 1970, 1994, 2002).',
  ),
  TriviaQuestion(
    question: 'Who scored the "Hand of God" goal?',
    options: ['Diego Maradona', 'Pelé', 'Gary Lineker', 'Zinedine Zidane'],
    correctIndex: 0,
    fact: 'Maradona scored it in the 1986 quarterfinal vs England.',
  ),
  TriviaQuestion(
    question: 'Which stadium will host the 2026 final?',
    options: ['SoFi Stadium', 'MetLife Stadium', 'Azteca Stadium', 'AT&T Stadium'],
    correctIndex: 1,
    fact: 'MetLife Stadium in New Jersey will host the final.',
  ),
  TriviaQuestion(
    question: 'Which player has the most World Cup appearances?',
    options: ['Lionel Messi', 'Lothar Matthäus', 'Cristiano Ronaldo', 'Paolo Maldini'],
    correctIndex: 1,
    fact: 'Matthäus played 25 matches across five World Cups.',
  ),
  TriviaQuestion(
    question: 'In which year was the World Cup trophy stolen?',
    options: ['1966', '1970', '1974', '1982'],
    correctIndex: 0,
    fact: 'The Jules Rimet trophy was stolen in England 1966, found by a dog.',
  ),
  TriviaQuestion(
    question: 'Which country hosted the 2014 World Cup?',
    options: ['South Africa', 'Germany', 'Brazil', 'Russia'],
    correctIndex: 2,
    fact: 'Brazil hosted in 2014, Germany won.',
  ),
  TriviaQuestion(
    question: 'What is the fastest goal in World Cup history?',
    options: ['11 seconds', '15 seconds', '20 seconds', '8 seconds'],
    correctIndex: 0,
    fact: 'Hakan Şükür scored after 11 seconds for Turkey vs South Korea in 2002.',
  ),
  TriviaQuestion(
    question: 'Which country has played in the most World Cup finals without winning?',
    options: ['Netherlands', 'Hungary', 'Sweden', 'Croatia'],
    correctIndex: 0,
    fact: 'Netherlands lost 3 finals (1974, 1978, 2010).',
  ),
  TriviaQuestion(
    question: 'Who was the top scorer of the 2022 World Cup?',
    options: ['Kylian Mbappé', 'Lionel Messi', 'Olivier Giroud', 'Julián Álvarez'],
    correctIndex: 0,
    fact: 'Mbappé scored 8 goals in Qatar 2022.',
  ),
  TriviaQuestion(
    question: 'How many World Cups has the USA hosted before 2026?',
    options: ['0', '1', '2', '3'],
    correctIndex: 1,
    fact: 'The USA hosted in 1994.',
  ),
  TriviaQuestion(
    question: 'Which was the first African country to reach the World Cup semifinals?',
    options: ['Nigeria', 'Senegal', 'Morocco', 'Cameroon'],
    correctIndex: 2,
    fact: 'Morocco reached the semis in 2022.',
  ),
  TriviaQuestion(
    question: 'Who scored the "bicycle kick" goal in the 2018 World Cup?',
    options: ['Cristiano Ronaldo', 'Sadio Mané', 'Benjamin Pavard', 'Kylian Mbappé'],
    correctIndex: 2,
    fact: 'Pavard scored a stunning volley vs Argentina in 2018.',
  ),
  TriviaQuestion(
    question: 'Which country has participated in every World Cup?',
    options: ['Germany', 'Italy', 'Brazil', 'Argentina'],
    correctIndex: 2,
    fact: 'Brazil is the only country to play in all 22 editions.',
  ),
  TriviaQuestion(
    question: 'What was the highest scoring World Cup final?',
    options: ['5-2', '6-3', '4-2', '7-1'],
    correctIndex: 0,
    fact: 'Brazil 5-2 Sweden in 1958 final.',
  ),
  TriviaQuestion(
    question: 'Which goalkeeper has the most clean sheets in World Cup history?',
    options: ['Gianluigi Buffon', 'Iker Casillas', 'Peter Shilton', 'Fabien Barthez'],
    correctIndex: 1,
    fact: 'Casillas kept 10 clean sheets across 2010 and 2014.',
  ),
  TriviaQuestion(
    question: 'How many goals did Pelé score in World Cups?',
    options: ['10', '12', '14', '8'],
    correctIndex: 1,
    fact: 'Pelé scored 12 goals in 14 World Cup matches.',
  ),
  TriviaQuestion(
    question: 'Which country will host the 2030 World Cup?',
    options: ['Saudi Arabia', 'Spain-Portugal-Morocco', 'Argentina-Uruguay-Paraguay', 'England'],
    correctIndex: 1,
    fact: '2030 will be hosted across Spain, Portugal and Morocco.',
  ),
  TriviaQuestion(
    question: 'Who captained Argentina to the 2022 World Cup title?',
    options: ['Ángel Di María', 'Lionel Messi', 'Emiliano Martínez', 'Nicolás Otamendi'],
    correctIndex: 1,
    fact: 'Messi captained Argentina to victory in Qatar.',
  ),
  TriviaQuestion(
    question: 'What is the oldest World Cup stadium still in use?',
    options: ['Maracanã', 'Wembley', 'Estadio Azteca', 'Centenario'],
    correctIndex: 2,
    fact: 'Estadio Azteca (Mexico) hosted in 1970, 1986 and will host in 2026.',
  ),
  TriviaQuestion(
    question: 'Which team scored the most goals in a single World Cup?',
    options: ['Hungary 1982', 'Hungary 1954', 'Brazil 1970', 'Germany 2014'],
    correctIndex: 1,
    fact: 'Hungary scored 27 goals in 1954.',
  ),
  TriviaQuestion(
    question: 'Who was the youngest goalscorer in World Cup history?',
    options: ['Pelé', 'Lionel Messi', 'Kylian Mbappé', 'Michael Owen'],
    correctIndex: 0,
    fact: 'Pelé was 17 years old when he scored in the 1958 final.',
  ),
  TriviaQuestion(
    question: 'Which country has the best World Cup win percentage?',
    options: ['Brazil', 'Germany', 'Argentina', 'Italy'],
    correctIndex: 0,
    fact: 'Brazil has won approximately 70% of their World Cup matches.',
  ),
  TriviaQuestion(
    question: 'How many World Cup tournaments have been held in total?',
    options: ['20', '22', '21', '18'],
    correctIndex: 1,
    fact: '22 World Cups were held from 1930 to 2022.',
  ),
  TriviaQuestion(
    question: 'Which country has hosted the World Cup most times?',
    options: ['Italy', 'Germany', 'Mexico', 'France'],
    correctIndex: 2,
    fact: 'Mexico hosted in 1970, 1986, and will host again in 2026.',
  ),
  TriviaQuestion(
    question: 'Who won the Golden Ball in the 2018 World Cup?',
    options: ['Kylian Mbappé', 'Antoine Griezmann', 'Luka Modrić', 'Eden Hazard'],
    correctIndex: 2,
    fact: 'Modrić won Best Player despite Croatia finishing runners-up.',
  ),
  TriviaQuestion(
    question: 'What was the score of the 2022 World Cup final?',
    options: ['3-1', '3-3 (Argentina won on pens)', '2-1', '4-2'],
    correctIndex: 1,
    fact: 'Argentina beat France 4-2 on penalties after a 3-3 draw.',
  ),
  TriviaQuestion(
    question: 'Which federation has won the most World Cups?',
    options: ['CONMEBOL', 'UEFA', 'CAF', 'CONCACAF'],
    correctIndex: 0,
    fact: 'CONMEBOL (South America) has 10 titles, UEFA (Europe) has 12.',
  ),
];
