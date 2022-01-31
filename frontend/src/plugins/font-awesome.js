import {library} from '@fortawesome/fontawesome-svg-core'
import {FontAwesomeIcon, FontAwesomeLayers} from '@fortawesome/vue-fontawesome'

import {faGithub} from "@fortawesome/free-brands-svg-icons/faGithub";
import {faExclamationTriangle} from "@fortawesome/free-solid-svg-icons/faExclamationTriangle";
import {faQuestionCircle} from "@fortawesome/free-solid-svg-icons/faQuestionCircle";
import {faCheck} from "@fortawesome/free-solid-svg-icons/faCheck";

library.add(faGithub);
library.add(faExclamationTriangle);
library.add(faQuestionCircle);
library.add(faCheck);

export default (app) => {
    app.component('font-awesome-icon', FontAwesomeIcon);
    app.component('font-awesome-layers', FontAwesomeLayers);
}
