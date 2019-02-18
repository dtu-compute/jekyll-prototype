class Exercise {
    static replaceHints() {
        //return;

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

            let text, btn_style;
            if (dependentElement.className.match(/\bhint\b/)) {
                text = "Show Hint!";
                btn_style = 'btn-hidden-directive btn-hint';
            } else {
                text = "Show Answer!";
                btn_style = 'btn-hidden-directive btn-answer';
            }

            const button = document.createElement('button');
            button.type = 'button';
            button.name = 'btn';
            button.setAttribute('data-question-id', question.id);
            button.innerText = text;
            button.className = `btn btn-primary ${btn_style}`;

            dependentElement.appendChild(button);

            const clusterList = questionClusters.get(question.id) || [];
            clusterList.push(dependentElement);
            questionClusters.set(question.id, clusterList);
        }

        for (let [questionId, dependentElements] of questionClusters) {
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
                        nextDependentElement.querySelector('button').addEventListener('click', makeClickListener(nextElements))
                    }
                    event.preventDefault();
                    return true;
                };

                if (dependentElementIndex === 0) {
                    dependentElement.querySelector('button').addEventListener('click', makeClickListener(dependentElements.slice(1)))
                } else {
                    dependentElement.classList.add('hide-dependent')
                }
            }
        }
    }
}

window.addEventListener("DOMContentLoaded", () => Exercise.replaceHints());

/*
window.enforceGroupPermission = function(groups) {
  console.dir(groups);
  const group_names = (Array.from(groups).map((group) => group.group));
  console.log(`enforceGroupPermission: ${JSON.stringify(group_names)}`);
  console.dir(group_names);
  return $(".only").each(function(el) {
    const me = $(this);
    const only_groups = me.data("only-groups").split(" ");
    console.log("only ");
    console.log(only_groups);
    const int = _.intersection(only_groups, group_names);
    console.log("intersection ");
    console.log(int);
    if (int.length) {
      return me.show();
    }
  });
};

*/