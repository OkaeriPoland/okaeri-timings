import {library} from '@fortawesome/fontawesome-svg-core'
import {FontAwesomeIcon, FontAwesomeLayers} from '@fortawesome/vue-fontawesome'

import {faGithub} from "@fortawesome/free-brands-svg-icons/faGithub";
import {faExclamationTriangle} from "@fortawesome/free-solid-svg-icons/faExclamationTriangle";
import {faQuestionCircle} from "@fortawesome/free-solid-svg-icons/faQuestionCircle";

library.add(faGithub);
library.add(faExclamationTriangle);
library.add(faQuestionCircle);

export default (app) => {
    app.component('font-awesome-icon', FontAwesomeIcon);
    app.component('font-awesome-layers', FontAwesomeLayers);
}
