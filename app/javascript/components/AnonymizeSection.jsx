import React, {useState} from 'react'
import Modal from 'react-modal';
import axios from 'axios'

const AnonymizeSection = ({database, currentTableName, currentTableColumns}) => {
  const [modalIsOpen, setIsOpen] = useState(false);

  console.log(database)
  console.log(currentTableName)
  console.log(currentTableColumns)

  const sendToAnonymize = async () => {
    const response = await axios.post(`/database/${database.id}/anonymize`)
     if (response.data.success) {
       window.location.href = "/"
     }
  }

  return (<div>
    <button onClick={() => setIsOpen(true)} className="btn btn-info">Start Anonymization</button>
    <Modal
      isOpen={modalIsOpen}
      onRequestClose={() => setIsOpen(false)}
      contentLabel="Example Modal"
      ariaHideApp={false}
    >
      <div>I am a modal</div>
      <form>
        <input />
        <button>tab navigation</button>
        <button>stays</button>
        <button>inside</button>
        <button>the modal</button>
      </form>
      <button className="btn-danger btn" onClick={()=>sendToAnonymize()}>Anonymize</button>
    </Modal>
  </div>)
}

export default AnonymizeSection