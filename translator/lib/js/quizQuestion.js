class QuizQuestion {
  constructor(rootEl = document) {
    console.log('init');

    [...rootEl.querySelectorAll('.olist.quiz-question-mc')].forEach((answerList) => {
      const answerCheckboxes = [...answerList.querySelectorAll('input[type="radio"]')];
      answerCheckboxes.forEach((answerCheckbox) => {
        console.log(answerCheckbox);
        answerCheckbox.addEventListener('change', (e) => {
          if (e.target.checked) {
            answerCheckboxes
              .filter(answerCheckbox => answerCheckbox !== e.target)
              .forEach((answerCheckbox) => { answerCheckbox.checked = false; answerCheckbox.parentNode.parentNode.classList.remove('answer-selected') });
            e.target.parentNode.parentNode.classList.add('answer-selected');
          }
          console.log(e);
        })
      })
    })
  }

  static resolve(questionId) {
    const el = document.querySelector(`.quiz-question[data-question-id="${questionId}"`);
    console.log(el.dataset.questionType);
    if (el.dataset.questionType === 'ata') QuizQuestion.resolve_ata(el);
    if (el.dataset.questionType === 'gap') QuizQuestion.resolve_gap(el);
  }

  static resolve_ata(el) {
    const answers = el.querySelectorAll('.quiz-answer');
    [...answers].forEach((answer) => {
      const selected = answer.querySelector('input').checked;
      const right = answer.classList.contains('answer-right');
      console.log(`${selected} ${right}`)
      if (selected === right) {
        answer.classList.add('answer-correct');
      } else {
        answer.classList.add('answer-incorrect');
      }
      answer.classList.add('answer-checked');
    })
  }

  static resolve_gap(el) {
    const gaps = [...el.querySelectorAll('.gap')];
    console.dir(gaps);
    gaps.forEach((gap) => {
      const input = gap.querySelector('input');
      const answer = gap.querySelector('.gap-answer');
      console.log(`${input.value} === ${answer.innerText}`);
      const correct = input.value === answer.innerText;
      gap.classList.add(correct ? 'answer-correct' : 'answer-incorrect');
    })
  }

  static reset(questionId) {
    const el = document.querySelector(`.quiz-question[data-question-id="${questionId}"`);
    if (el.dataset.questionType === 'ata') QuizQuestion.reset_ata(el);
    if (el.dataset.questionType === 'gap') QuizQuestion.reset_gap(el);
  }

  static reset_ata(el) {
    const answers = el.querySelectorAll('.quiz-answer');
    [...answers].forEach((answer) => {
      answer.querySelector('input').checked = false;
      answer.classList.remove('answer-correct');
      answer.classList.remove('answer-incorrect');
      answer.classList.remove('answer-checked');
    });
  }

  static reset_gap(el) {
    const gaps = [...el.querySelectorAll('.gap')];
    gaps.forEach((gap) => {
      gap.classList.remove('answer-correct' );
      gap.classList.remove('answer-incorrect');
    })
  }

}

