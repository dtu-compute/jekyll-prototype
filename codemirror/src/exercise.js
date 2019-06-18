class Exercise {
  static replaceHints () {
    // return;

    const findQuestion = (element) => {
      let sibling = element;
      while (sibling) {
        sibling = sibling.previousElementSibling;
        if (sibling.className.match(/\bquestion\b/)) {
          return sibling;
        }
      }
      return null;
    };

    const dependentElements = document.querySelectorAll('.hint, .answer');

    let questionClusters = new Map();

    for (const dependentElement of dependentElements) {
      const question = findQuestion(dependentElement);

      dependentElement.classList.add('qha-content-hidden');

      let text, btnStyle;
      if (dependentElement.className.match(/\bhint\b/)) {
        text = 'Show Hint!';
        btnStyle = 'btn-hidden-directive btn-hint';
      } else {
        text = 'Show Answer!';
        btnStyle = 'btn-hidden-directive btn-answer';
      }

      const button = document.createElement('button');
      button.type = 'button';
      button.name = 'btn';
      button.setAttribute('data-question-id', question.id);
      button.innerText = text;
      button.className = `btn btn-primary ${btnStyle}`;

      dependentElement.appendChild(button);

      const clusterList = questionClusters.get(question.id) || [];
      clusterList.push(dependentElement);
      questionClusters.set(question.id, clusterList);
    }

    // /* _questionId */
    for (let [, dependentElements] of questionClusters) {
      for (let dependentElementIndex = 0; dependentElementIndex < dependentElements.length; dependentElementIndex++) {
        const dependentElement = dependentElements[dependentElementIndex];

        const makeClickListener = (nextElements) => (event) => {
          const button = event.currentTarget;
          button.parentNode.classList.remove('qha-content-hidden');
          button.parentNode.removeChild(button);
          const nextDependentElement = nextElements.shift();
          console.log(`${nextDependentElement} remaining ${nextElements.length}`);
          if (nextDependentElement) {
            nextDependentElement.classList.remove('hide-dependent');
            nextDependentElement.querySelector('button').addEventListener('click', makeClickListener(nextElements));
          }
          event.preventDefault();
          return true;
        };

        if (dependentElementIndex === 0) {
          dependentElement.querySelector('button').addEventListener('click', makeClickListener(dependentElements.slice(1)));
        } else {
          dependentElement.classList.add('hide-dependent');
        }
      }
    }
  }
}

/*

== hello

[question]
.....

Bestem samtlige stationære punkter for latexmath:[\,f\,.]

.....

[question]
.....

Bestem Hessematricen for latexmath:[\,f\,,] og gør rede for at
latexmath:[\,f\,] har netop ét egentligt lokalt minimum og ingen
egentlige lokale maxima.

.....

 */
export default Exercise;
